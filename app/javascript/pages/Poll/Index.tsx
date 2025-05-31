import { Head, Link } from '@inertiajs/react'
import { Clock, AlertCircle, CheckCircle2 } from 'lucide-react'

import Layout from '../Layout'

import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'

interface Poll {
  id: number;
  name: string;
  description: string;
  creator: {
    email: string;
  };
  created_at: string;
  end_voting_at: string;
  path: string;
  vote_path: string;
}

interface IndexProps {
  polls: Poll[];
  new_poll_path?: string;
}

function DeadlineDisplay({ endVotingAt }: { endVotingAt: string }) {
  const now = new Date()
  const deadline = new Date(endVotingAt)
  const isExpired = deadline < now
  const timeDiff = deadline.getTime() - now.getTime()

  // Calculate time remaining
  const days = Math.floor(timeDiff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((timeDiff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((timeDiff % (1000 * 60 * 60)) / (1000 * 60))

  let timeText = ''
  let urgencyLevel = 'normal' // normal, urgent, expired

  if (isExpired) {
    timeText = 'Voting closed'
    urgencyLevel = 'expired'
  } else if (days > 0) {
    timeText = `${days} day${days > 1 ? 's' : ''} left`
    urgencyLevel = days <= 1 ? 'urgent' : 'normal'
  } else if (hours > 0) {
    timeText = `${hours}h ${minutes}m left`
    urgencyLevel = 'urgent'
  } else {
    timeText = `${minutes}m left`
    urgencyLevel = 'urgent'
  }

  const getIcon = () => {
    if (isExpired) return <CheckCircle2 className="h-4 w-4" />
    if (urgencyLevel === 'urgent') return <AlertCircle className="h-4 w-4" />
    return <Clock className="h-4 w-4" />
  }

  const getBadgeVariant = () => {
    if (isExpired) return 'secondary'
    if (urgencyLevel === 'urgent') return 'destructive'
    return 'default'
  }

  return (
    <div className="flex items-center gap-2">
      <Badge variant={getBadgeVariant()} className="flex items-center gap-1">
        {getIcon()}
        {timeText}
      </Badge>
      <span className="text-xs text-muted-foreground">
        Ends {deadline.toLocaleDateString()} at {deadline.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
      </span>
    </div>
  )
}

export default function Index({ polls = [], new_poll_path }: IndexProps) {
  return (
    <Layout new_poll_path={new_poll_path}>
      <Head title="Browse Polls" />
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold">Browse Polls</h1>
            <p className="text-sm text-muted-foreground mt-1">
              View all available polls for your events.
            </p>
          </div>
          {polls.length > 0 && (
            <div>
              <Link href="/polls/new">
                <Button>Create New Poll</Button>
              </Link>
            </div>
          )}
        </div>

        {polls.length === 0 ? (
          <div className="text-center py-12">
            <h3 className="text-lg font-medium text-muted-foreground mb-4">No polls available yet</h3>
            <p className="text-sm text-muted-foreground mb-6">
              Be the first to create a poll for your event!
            </p>
            <Link href="/polls/new">
              <Button>Create New Poll</Button>
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {polls.map((poll) => (
              <div
                key={poll.id}
                className="border rounded-lg p-4 hover:bg-accent/50 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="text-lg font-medium">{poll.name}</h3>
                    <p className="text-sm text-muted-foreground mt-1">
                      Created by {poll.creator.email}
                    </p>
                  </div>
                  <div className="flex gap-2">
                    {new Date(poll.end_voting_at) > new Date() ? (
                      <Link href={poll.vote_path}>
                        <Button variant="default" size="sm">Cast Vote</Button>
                      </Link>
                    ) : (
                      <Button variant="default" size="sm" disabled>
                        Voting Closed
                      </Button>
                    )}
                    <Link href={poll.path}>
                      <Button variant="outline" size="sm">View Poll</Button>
                    </Link>
                  </div>
                </div>
                <p className="mt-2 text-sm line-clamp-2">{poll.description}</p>
                <div className="mt-3 flex flex-col gap-2">
                  <DeadlineDisplay endVotingAt={poll.end_voting_at} />
                  <div className="text-xs text-muted-foreground">
                    Created on {new Date(poll.created_at).toLocaleDateString()}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </Layout>
  )
}
