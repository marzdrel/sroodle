import { Head, useForm, router } from '@inertiajs/react'

import Layout from '../Layout'

import VoteForm from '@/components/VoteForm'

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

interface NewProps {
  poll: Poll;
  errors?: Record<string, string> | string[];
  flash?: {
    notice?: string;
    alert?: string;
  };
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

export default function New({ poll, errors = {}, flash }: NewProps) {
  const inertiaForm = useForm<VoteFormData>({
    vote: {
      name: '',
      email: '',
      responses: {}
    }
  })

  // Handle case where poll might be undefined
  if (!poll) {
    return (
      <Layout>
        <Head title="Vote - Poll Not Found" />
        <div className="max-w-4xl mx-auto">
          <div className="text-center py-10">
            <h1 className="text-2xl font-bold text-red-600">Poll not found</h1>
            <p className="text-muted-foreground mt-2">The poll you're looking for doesn't exist.</p>
          </div>
        </div>
      </Layout>
    )
  }

  const handleSubmit = (formData: VoteFormData) => {
    router.post(`/polls/${poll.id}/votes`, formData)
  }

  return (
    <Layout>
      <Head title={`Vote on ${poll.name}`} />
      <VoteForm
        poll={poll}
        errors={errors}
        flash={flash}
        mode="new"
        onSubmit={handleSubmit}
        processing={inertiaForm.processing}
      />
    </Layout>
  )
}
