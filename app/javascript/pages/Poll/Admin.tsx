import { Head, Link } from '@inertiajs/react'

import Layout from '../Layout'

import { Button } from '@/components/ui/button'

interface PollOption {
  id: string;
  start: string;
  duration_minutes: number;
}

interface Poll {
  id: string;
  name: string;
  description: string;
  organizer_name: string;
  end_voting_at: string;
  path: string;
  options: PollOption[];
}

interface Links {
  public: string;
  vote: string;
  admin: string;
}

interface AdminProps {
  poll: Poll;
  links: Links;
  participants_count: number;
  new_poll_path?: string;
  debug?: string;
}

function LinkRow({ label, url, hint }: { label: string; url: string; hint: string }) {
  return (
    <div className="space-y-1">
      <div className="text-sm font-medium">{label}</div>
      <code className="block break-all rounded-md bg-muted px-3 py-2 text-sm">{url}</code>
      <p className="text-xs text-muted-foreground">{hint}</p>
    </div>
  )
}

export default function Admin({ poll, links, participants_count, new_poll_path, debug }: AdminProps) {
  return (
    <Layout new_poll_path={new_poll_path} debug={debug}>
      <Head title={`Manage ${poll.name}`} />
      <div className="max-w-4xl mx-auto space-y-8">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm text-muted-foreground">Organizer page</p>
            <h1 className="text-3xl font-bold">{poll.name}</h1>
            <p className="text-sm text-muted-foreground mt-1">
              {participants_count === 1 ? '1 person has answered' : `${participants_count} people have answered`}
            </p>
          </div>
          <Link href={poll.path}>
            <Button variant="outline">View results</Button>
          </Link>
        </div>

        <section className="space-y-4 rounded-lg border p-6">
          <h2 className="text-lg font-medium">Share with participants</h2>
          <LinkRow
            label="Poll link"
            url={links.public}
            hint="Send this to everyone you want to invite. They can vote and see the results."
          />
        </section>

        <section className="space-y-4 rounded-lg border border-amber-300 bg-amber-50 p-6">
          <h2 className="text-lg font-medium">Your private admin link</h2>
          <LinkRow
            label="Admin link"
            url={links.admin}
            hint="Save this link and don't share it. It's the only way to manage this poll."
          />
        </section>
      </div>
    </Layout>
  )
}
