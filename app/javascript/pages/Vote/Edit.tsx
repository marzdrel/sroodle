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
  name: string;
  email: string;
  responses: Record<string, string>;
}

interface EditProps {
  poll: Poll;
  votes: Vote;
  errors?: Record<string, string> | string[];
  flash?: {
    notice?: string;
    alert?: string;
  };
  new_poll_path?: string;
  logged_in?: boolean;
  debug?: string;
  user?: {
    email?: string;
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

export default function Edit({ poll, votes, errors = {}, flash, new_poll_path, logged_in = false, debug, user }: EditProps) {
  const inertiaForm = useForm<VoteFormData>({
    vote: {
      name: votes?.name || '',
      email: votes?.email || '',
      responses: votes?.responses || {}
    }
  })

  // Handle case where poll or vote might be undefined
  if (!poll || !votes) {
    return (
      <Layout new_poll_path={new_poll_path} debug={debug} user={user}>
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
    inertiaForm.setData(formData)
    inertiaForm.patch(`/${poll.id}/votes`)
  }

  return (
    <Layout new_poll_path={new_poll_path} debug={debug} user={user}>
      <Head title={`Edit Vote - ${poll.name}`} />
      <VoteForm
        poll={poll}
        vote={votes}
        errors={errors}
        flash={flash}
        mode="edit"
        onSubmit={handleSubmit}
        processing={inertiaForm.processing}
        logged_in={logged_in}
      />
    </Layout>
  )
}
