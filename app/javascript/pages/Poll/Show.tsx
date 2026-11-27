import { Head, Link } from '@inertiajs/react'
import { CheckCircle2, HelpCircle, XCircle } from 'lucide-react'

import Layout from '../Layout'

import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { formatOption } from '@/lib/options'

type Answer = 'yes' | 'maybe' | 'no'

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

interface Participant {
  id: string;
  name: string;
  you: boolean;
  responses: Record<string, Answer>;
}

interface Poll {
  id: string;
  name: string;
  description: string | null;
  organizer_name: string;
  created_at: string;
  end_voting_at: string;
  vote_path: string;
  edit_vote_path: string;
}

interface ShowProps {
  poll: Poll;
  options: PollOption[];
  participants: Participant[];
  best_option_ids: string[];
  you_voted: boolean;
  new_poll_path?: string;
  debug?: string;
}

const ANSWER_STYLES: Record<Answer, { className: string; label: string; icon: React.ReactNode }> = {
  yes: { className: 'bg-green-100 text-green-800', label: 'Yes', icon: <CheckCircle2 className="h-4 w-4" /> },
  maybe: { className: 'bg-yellow-100 text-yellow-800', label: 'Maybe', icon: <HelpCircle className="h-4 w-4" /> },
  no: { className: 'bg-red-100 text-red-800', label: 'No', icon: <XCircle className="h-4 w-4" /> },
}

function AnswerCell({ answer }: { answer?: Answer }) {
  if (!answer) {
    return <span className="mx-auto flex h-8 w-8 items-center justify-center rounded-full bg-gray-100 text-gray-400">–</span>
  }

  const style = ANSWER_STYLES[answer]

  return (
    <span
      className={`mx-auto flex h-8 w-8 items-center justify-center rounded-full ${style.className}`}
      title={style.label}
      aria-label={style.label}
    >
      {style.icon}
    </span>
  )
}

export default function Show({ poll, options, participants, best_option_ids, you_voted, new_poll_path, debug }: ShowProps) {
  const bestOptions = options.filter(option => best_option_ids.includes(option.id))

  return (
    <Layout new_poll_path={new_poll_path} debug={debug}>
      <Head title={`${poll.name} - Poll`} />
      <div className="mx-auto max-w-7xl space-y-8">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <h1 className="text-3xl font-bold">{poll.name}</h1>
            <p className="mt-1 text-sm text-muted-foreground">Organized by {poll.organizer_name}</p>
          </div>
          <div className="flex flex-wrap gap-3">
            <Link href={you_voted ? poll.edit_vote_path : poll.vote_path}>
              <Button>{you_voted ? 'Edit your answers' : 'Add your answers'}</Button>
            </Link>
          </div>
        </div>

        {poll.description && (
          <p className="whitespace-pre-line rounded-lg bg-muted/50 p-4 text-sm">{poll.description}</p>
        )}

        <section className="rounded-lg border bg-card p-6">
          <h2 className="mb-4 text-lg font-medium">Best {bestOptions.length === 1 ? 'date' : 'dates'}</h2>
          {bestOptions.length > 0 ? (
            <ul className="grid grid-cols-1 gap-4 md:grid-cols-2">
              {bestOptions.map(option => {
                const formatted = formatOption(option)

                return (
                  <li key={option.id} className="flex items-center justify-between rounded-md bg-muted/50 p-4" data-testid="best-option">
                    <div>
                      <div className="font-medium">{formatted.date}</div>
                      {formatted.time && <div className="text-sm text-muted-foreground">{formatted.time}</div>}
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge className="bg-green-100 text-green-800">{option.counts.yes} Yes</Badge>
                      <Badge className="bg-yellow-100 text-yellow-800">{option.counts.maybe} Maybe</Badge>
                    </div>
                  </li>
                )
              })}
            </ul>
          ) : (
            <p className="text-sm text-muted-foreground">No one is available yet.</p>
          )}
        </section>

        <section className="overflow-x-auto rounded-lg border bg-card p-6">
          <h2 className="mb-4 text-lg font-medium">All answers</h2>
          {participants.length > 0 ? (
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="pb-2 text-left font-medium">Participant</th>
                  {options.map(option => {
                    const formatted = formatOption(option)

                    return (
                      <th key={option.id} className="px-2 pb-2 text-center font-medium">
                        <div className="whitespace-nowrap">{formatted.shortDate}</div>
                        <div className="whitespace-nowrap text-xs text-muted-foreground">{formatted.weekday}</div>
                        {formatted.time && <div className="whitespace-nowrap text-xs text-muted-foreground">{formatted.time}</div>}
                      </th>
                    )
                  })}
                </tr>
              </thead>
              <tbody>
                {participants.map(participant => (
                  <tr key={participant.id} className="border-b">
                    <td className="py-3 font-medium">
                      {participant.name}
                      {participant.you && <span className="ml-2 text-xs text-muted-foreground">(you)</span>}
                    </td>
                    {options.map(option => (
                      <td key={option.id} className="text-center">
                        <AnswerCell answer={participant.responses[option.id]} />
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr>
                  <td className="pt-3 text-sm text-muted-foreground">Yes / Maybe</td>
                  {options.map(option => (
                    <td
                      key={option.id}
                      className={`pt-3 text-center text-sm ${best_option_ids.includes(option.id) ? 'font-bold text-green-700' : 'text-muted-foreground'}`}
                      data-testid={`total-${option.id}`}
                    >
                      {option.counts.yes} / {option.counts.maybe}
                    </td>
                  ))}
                </tr>
              </tfoot>
            </table>
          ) : (
            <div className="py-10 text-center">
              <p className="text-muted-foreground">No answers yet. Be the first!</p>
            </div>
          )}
        </section>
      </div>
    </Layout>
  )
}
