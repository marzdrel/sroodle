import { Head, useForm } from '@inertiajs/react'

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

interface Vote {
  id: string;
  name: string;
  email: string;
  responses: Record<string, string>;
}

interface EditProps {
  poll: Poll;
  vote: Vote;
  errors?: Record<string, string> | string[];
  flash?: {
    notice?: string;
    alert?: string;
  };
}

interface VoteFormData extends Record<string, any> {
  vote: {
    name: string;
    email: string;
    responses: Record<string, string>;
  };
  poll_id?: string;
}

export default function Edit({ poll, vote, errors = {}, flash }: EditProps) {
  const { put, processing } = useForm()

  // Handle case where poll or vote might be undefined
  if (!poll || !vote) {
    return (
      <Layout>
        <Head title="Edit Vote - Not Found" />
        <div className="max-w-4xl mx-auto">
          <div className="text-center py-10">
            <h1 className="text-2xl font-bold text-red-600">Vote not found</h1>
            <p className="text-muted-foreground mt-2">The vote you're trying to edit doesn't exist.</p>
          </div>
        </div>
      </Layout>
    )
  }

  const handleSubmit = (formData: VoteFormData) => {
    put(`/polls/${poll.id}/votes/${vote.id}`, formData)
  }

  return (
    <Layout>
      <Head title={`Edit Vote - ${poll.name}`} />
      <VoteForm
        poll={poll}
        vote={vote}
        errors={errors}
        flash={flash}
        mode="edit"
        onSubmit={handleSubmit}
        processing={processing}
      />
    </Layout>
  )
}
