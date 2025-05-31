import { CheckCircle2, HelpCircle, XCircle, Send, Edit } from 'lucide-react'
import * as React from 'react'
import { useForm as useReactHookForm } from 'react-hook-form'

import PollDescription from '@/components/PollDescription'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'

interface PollOption {
  id: string;
  start: string;
  duration_minutes: number;
}

interface Poll {
  id: string;
  name: string;
  description: string;
  options: PollOption[];
}

interface Vote {
  id?: string;
  name: string;
  email: string;
  responses: Record<string, string>;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
interface VoteFormData extends Record<string, any> {
  vote: {
    name: string;
    email: string;
    responses: Record<string, string>;
  };
  poll_id?: string;
}

interface VoteFormProps {
  poll: Poll;
  vote?: Vote;
  errors?: Record<string, string> | string[];
  flash?: {
    notice?: string;
    alert?: string;
  };
  mode: 'new' | 'edit';
  onSubmit: (data: VoteFormData) => void;
  processing: boolean;
  logged_in?: boolean;
}

export default function VoteForm({
  poll,
  vote,
  errors = {},
  flash,
  mode,
  onSubmit,
  processing,
  logged_in = false
}: VoteFormProps) {
  const form = useReactHookForm<VoteFormData>({
    defaultValues: {
      vote: {
        name: vote?.name || '',
        email: vote?.email || '',
        responses: vote?.responses || {}
      }
    }
  })

  // Watch all form values to get current state
  const watchedData = form.watch()

  // Handle server errors
  React.useEffect(() => {
    form.clearErrors();

    if (errors && !Array.isArray(errors)) {
      Object.entries(errors).forEach(([field, message]) => {
        const formPath = `vote.${field}`;

        if (field !== 'base') {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          form.setError(formPath as any, {
            type: 'server',
            message
          });
        }
      });
    }
  }, [errors, form]);

  // Track if form has been initialized to prevent overwriting user changes
  const formInitialized = React.useRef(false);

  // Initialize form data with initial values only once
  React.useEffect(() => {
    if (vote && mode === 'edit' && !formInitialized.current) {
      const newData = {
        vote: {
          name: vote.name,
          email: vote.email,
          responses: vote.responses
        }
      };
      form.reset(newData);
      formInitialized.current = true;
    }
  }, [vote, mode, form]);

  const handleSubmit = (formData: VoteFormData) => {
    const voteData = {
      ...formData,
      poll_id: poll.id
    }
    onSubmit(voteData)
  }

  const handleResponseChange = (optionId: string, response: string, onChange: (value: Record<string, string>) => void) => {
    const currentResponses = form.getValues('vote.responses') || {}
    const newResponses = {
      ...currentResponses,
      [optionId]: response
    }
    // Update both React Hook Form and our custom handler
    form.setValue('vote.responses', newResponses)
    onChange(newResponses)
  }

  const formatDateTime = (start: string, durationMinutes: number) => {
    const startDate = new Date(start)
    const endDate = new Date(startDate.getTime() + durationMinutes * 60000)

    return {
      date: startDate.toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }),
      time: `${startDate.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit'
      })} - ${endDate.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit'
      })}`
    }
  }

  const getResponseVariant = (response: string) => {
    switch (response) {
      case 'yes': return 'bg-green-100 text-green-800 border-green-200'
      case 'maybe': return 'bg-yellow-100 text-yellow-800 border-yellow-200'
      case 'no': return 'bg-red-100 text-red-800 border-red-200'
      default: return 'bg-gray-100 text-gray-800 border-gray-200'
    }
  }

  return (
    <div className="max-w-4xl mx-auto">
      {/* Flash Messages */}
      {flash?.notice && (
        <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
          <p className="text-green-800 text-sm">{flash.notice}</p>
        </div>
      )}
      {flash?.alert && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-800 text-sm">{flash.alert}</p>
        </div>
      )}

      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold">{poll.name}</h1>
        <PollDescription description={poll.description} />
      </div>

      {/* General Error Messages */}
      {errors && !Array.isArray(errors) && errors.base && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-800 text-sm">{errors.base}</p>
        </div>
      )}
      {Array.isArray(errors) && errors.length > 0 && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          {errors.map((error, index) => (
            <p key={index} className="text-red-800 text-sm">{error}</p>
          ))}
        </div>
      )}

      <Form {...form}>
        <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8">
          {/* Personal Information */}
          <div className="p-6 border rounded-lg bg-card">
            <h2 className="text-lg font-medium mb-4">Your Information</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="vote.name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Name</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="Your name"
                        {...field}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                          field.onChange(e)
                        }}
                      />
                    </FormControl>
                    <FormDescription>
                      Enter your full name.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="vote.email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input
                        type="email"
                        placeholder="your.email@example.com"
                        {...field}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                          field.onChange(e)
                        }}
                        readOnly={logged_in}
                      />
                    </FormControl>
                    <FormDescription>
                      We'll use this to send you poll updates.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </div>

        {/* Date Options */}
        <FormField
          control={form.control}
          name="vote.responses"
          render={({ field }) => (
            <FormItem>
              <div className="p-6 border rounded-lg bg-card">
                <FormLabel className="text-lg font-medium">Select Your Availability</FormLabel>
                <FormMessage className="mt-2" />
                <div className="space-y-4 mt-4">
                  {poll.options.map((option) => {
                    const { date, time } = formatDateTime(option.start, option.duration_minutes)
                    const currentResponse = watchedData.vote?.responses?.[option.id] || ''

                    return (
                      <div key={option.id} className="p-4 border rounded-lg">
                        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                          <div>
                            <h3 className="font-medium">{date}</h3>
                            <p className="text-sm text-muted-foreground">{time}</p>
                          </div>

                          <div className="flex gap-2">
                            {['yes', 'maybe', 'no'].map((response) => {
                              const getIcon = () => {
                                switch (response) {
                                  case 'yes': return <CheckCircle2 className="w-4 h-4 text-green-600" />
                                  case 'maybe': return <HelpCircle className="w-4 h-4 text-yellow-600" />
                                  case 'no': return <XCircle className="w-4 h-4 text-red-600" />
                                  default: return null
                                }
                              }

                              const getLabel = () => {
                                switch (response) {
                                  case 'yes': return 'Yes'
                                  case 'maybe': return 'Maybe'
                                  case 'no': return 'No'
                                  default: return ''
                                }
                              }

                              return (
                                <button
                                  key={response}
                                  type="button"
                                  onClick={() => handleResponseChange(option.id, response, field.onChange)}
                                  className={`px-4 py-2 rounded-md border transition-all flex items-center gap-2 ${
                                    currentResponse === response
                                      ? getResponseVariant(response)
                                      : 'bg-gray-50 text-gray-700 border-gray-200 hover:bg-gray-100'
                                  }`}
                                >
                                  {getIcon()}
                                  {getLabel()}
                                </button>
                              )
                            })}
                          </div>
                        </div>
                      </div>
                    )
                  })}
                </div>
              </div>
            </FormItem>
          )}
        />

        {/* Submit Button */}
        <div className="flex justify-end">
          <Button type="submit" disabled={processing} className="px-8 flex items-center gap-2">
            {mode === 'edit' ? <Edit className="w-4 h-4 text-white" /> : <Send className="w-4 h-4 text-white" />}
            {processing ? (mode === 'edit' ? 'Updating...' : 'Submitting...') : (mode === 'edit' ? 'Update Vote' : 'Submit Vote')}
          </Button>
        </div>
      </form>
      </Form>
    </div>
  )
}
