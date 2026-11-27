import { Head, Link, router } from '@inertiajs/react'
import { useState } from 'react'

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
  path: string;
  options: PollOption[];
}

type Vote = {
  name: string;
  email: string;
  responses: Record<string, string>;
};

interface EditProps {
  poll: Poll;
  vote: Vote;
  submit_path: string;
  edit_link?: string;
  errors?: Record<string, string> | string[];
  new_poll_path?: string;
  debug?: string;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
interface VoteFormData extends Record<string, any> {
  vote: Vote;
}

export default function Edit({ poll, vote, submit_path, edit_link, errors = {}, new_poll_path, debug }: EditProps) {
  const [processing, setProcessing] = useState(false)

  const handleSubmit = (formData: VoteFormData) => {
    router.patch(submit_path, { vote: formData.vote }, {
      onStart: () => setProcessing(true),
      onFinish: () => setProcessing(false),
    })
  }

  const editUrl = edit_link && typeof window !== 'undefined'
    ? new URL(edit_link, window.location.origin).toString()
    : edit_link

  return (
    <Layout new_poll_path={new_poll_path} debug={debug}>
      <Head title={`Edit Vote - ${poll.name}`} />
      <VoteForm
        poll={poll}
        vote={vote}
        errors={errors}
        mode="edit"
        onSubmit={handleSubmit}
        processing={processing}
      />
      <div className="max-w-4xl mx-auto mt-8 space-y-3 text-sm text-muted-foreground">
        {editUrl && (
          <p>
            To change your answers from another device, open your personal link:{' '}
            <code className="break-all text-foreground" data-testid="edit-link">{editUrl}</code>
          </p>
        )}
        <p>
          <Link href={poll.path} className="font-medium text-primary hover:underline">
            See everyone's answers
          </Link>
        </p>
      </div>
    </Layout>
  )
}
