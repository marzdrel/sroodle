import { Head, router } from '@inertiajs/react'
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
  options: PollOption[];
}

type Vote = {
  name: string;
  email: string;
  responses: Record<string, string>;
};

interface NewProps {
  poll: Poll;
  vote?: Vote;
  submit_path: string;
  errors?: Record<string, string> | string[];
  new_poll_path?: string;
  debug?: string;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
interface VoteFormData extends Record<string, any> {
  vote: Vote;
}

export default function New({ poll, vote, submit_path, errors = {}, new_poll_path, debug }: NewProps) {
  const [processing, setProcessing] = useState(false)

  const handleSubmit = (formData: VoteFormData) => {
    router.post(submit_path, { vote: formData.vote }, {
      onStart: () => setProcessing(true),
      onFinish: () => setProcessing(false),
    })
  }

  return (
    <Layout new_poll_path={new_poll_path} debug={debug}>
      <Head title={`Vote on ${poll.name}`} />
      <VoteForm
        poll={poll}
        vote={vote}
        errors={errors}
        mode="new"
        onSubmit={handleSubmit}
        processing={processing}
      />
    </Layout>
  )
}
