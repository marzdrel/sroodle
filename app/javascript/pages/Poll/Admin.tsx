import { Head, Link, router } from '@inertiajs/react'
import { CheckCircle2 } from 'lucide-react'

import Layout from '../Layout'

import CopyButton from '@/components/CopyButton'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { formatOption } from '@/lib/options'

interface Counts {
  yes: number;
  maybe: number;
  no: number;
}

interface PollOption {
  id: string;
  start: string;
  duration_minutes: number;
  counts: Counts;
}

interface Poll {
  id: string;
  name: string;
  description: string;
  organizer_name: string;
  end_voting_at: string;
  path: string;
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
  options: PollOption[];
  best_option_ids: string[];
  closed: boolean;
  voting_open: boolean;
  final_option_id: string | null;
  close_path: string;
  reopen_path: string;
  new_poll_path?: string;
  debug?: string;
}

function LinkRow({ label, url, hint, copyLabel }: { label: string; url: string; hint: string; copyLabel: string }) {
  return (
    <div className="space-y-2">
      <div className="text-sm font-medium">{label}</div>
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
        <code className="block flex-1 break-all rounded-md bg-muted px-3 py-2 text-sm">{url}</code>
        <CopyButton value={url} label={copyLabel} />
      </div>
      <p className="text-xs text-muted-foreground">{hint}</p>
    </div>
  )
}

export default function Admin({
  poll, links, participants_count, options, best_option_ids, closed, voting_open,
  final_option_id, close_path, reopen_path, new_poll_path, debug,
}: AdminProps) {
  const pickDate = (optionId: string) => {
    router.post(close_path, { option_id: optionId })
  }

  const reopen = () => {
    router.post(reopen_path)
  }

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
              {' · '}
              {closed ? 'Closed' : voting_open ? 'Voting open' : 'Voting deadline passed'}
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
            copyLabel="Copy poll link"
            hint="Send this to everyone you want to invite. They can vote and see the results."
          />
        </section>

        <section className="space-y-4 rounded-lg border p-6">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
            <h2 className="text-lg font-medium">{closed ? 'Final date' : 'Pick the final date'}</h2>
            {closed && (
              <Button variant="outline" onClick={reopen}>Reopen voting</Button>
            )}
          </div>
          {!closed && (
            <p className="text-sm text-muted-foreground">
              Picking a date closes voting and shows the date to everyone on the poll page.
            </p>
          )}
          <ul className="space-y-2">
            {options.map(option => {
              const formatted = formatOption(option)
              const isFinal = option.id === final_option_id
              const isBest = best_option_ids.includes(option.id)

              return (
                <li
                  key={option.id}
                  data-testid={`option-${option.id}`}
                  className={`flex flex-col gap-2 rounded-md border p-3 sm:flex-row sm:items-center sm:justify-between ${isFinal ? 'border-green-400 bg-green-50' : ''}`}
                >
                  <div>
                    <div className="font-medium">
                      {formatted.date}
                      {isBest && !closed && <Badge className="ml-2 bg-green-100 text-green-800">Best</Badge>}
                    </div>
                    {formatted.time && <div className="text-sm text-muted-foreground">{formatted.time}</div>}
                    <div className="text-xs text-muted-foreground">
                      {option.counts.yes} yes · {option.counts.maybe} maybe · {option.counts.no} no
                    </div>
                  </div>
                  {isFinal ? (
                    <span className="flex items-center gap-1 text-sm font-medium text-green-800">
                      <CheckCircle2 className="h-4 w-4" /> Chosen
                    </span>
                  ) : (
                    !closed && (
                      <Button size="sm" variant={isBest ? 'default' : 'outline'} onClick={() => pickDate(option.id)}>
                        Pick this date
                      </Button>
                    )
                  )}
                </li>
              )
            })}
          </ul>
        </section>

        <section className="space-y-4 rounded-lg border border-amber-300 bg-amber-50 p-6">
          <h2 className="text-lg font-medium">Your private admin link</h2>
          <LinkRow
            label="Admin link"
            url={links.admin}
            copyLabel="Copy admin link"
            hint="Save this link and don't share it. It's the only way to manage this poll."
          />
        </section>
      </div>
    </Layout>
  )
}
