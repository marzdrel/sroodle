import { Head, Link } from '@inertiajs/react'

import Layout from '../Layout'

import { Button } from '@/components/ui/button'

interface Poll {
  id: number;
  name: string;
  description: string;
  creator: {
    email: string;
  };
  created_at: string;
  path: string;
  vote_path: string;
}

interface IndexProps {
  polls: Poll[];
  new_poll_path?: string;
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
                    <Link href={poll.vote_path}>
                      <Button variant="default" size="sm">Cast Vote</Button>
                    </Link>
                    <Link href={poll.path}>
                      <Button variant="outline" size="sm">View Poll</Button>
                    </Link>
                  </div>
                </div>
                <p className="mt-2 text-sm line-clamp-2">{poll.description}</p>
                <div className="mt-3 text-xs text-muted-foreground">
                  Created on {new Date(poll.created_at).toLocaleDateString()}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </Layout>
  )
}
