import { Link } from '@inertiajs/react'

import { Badge } from '@/components/ui/badge'

export interface MyPoll {
  id: string;
  name: string;
  path: string;
  admin_path: string | null;
  role: 'organizer' | 'participant';
  closed: boolean;
}

// Polls this browser created or answered. Only shown to this browser.
export default function YourPolls({ polls }: { polls: MyPoll[] }) {
  if (polls.length === 0) {
    return null
  }

  return (
    <section className="mb-10 rounded-lg border p-4" aria-labelledby="your-polls">
      <h2 id="your-polls" className="mb-3 text-lg font-medium">Your polls</h2>
      <ul className="divide-y">
        {polls.map(poll => (
          <li key={poll.id} className="flex items-center justify-between gap-3 py-2">
            <div className="flex items-center gap-2">
              <Link href={poll.path} className="font-medium hover:underline">{poll.name}</Link>
              <Badge variant="secondary">{poll.role === 'organizer' ? 'Organizer' : 'Voted'}</Badge>
              {poll.closed && <Badge variant="outline">Closed</Badge>}
            </div>
            {poll.admin_path && (
              <Link href={poll.admin_path} className="text-sm text-primary hover:underline">Manage</Link>
            )}
          </li>
        ))}
      </ul>
    </section>
  )
}
