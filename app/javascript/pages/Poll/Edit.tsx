import { Head, Link, router } from '@inertiajs/react'
import { useState } from 'react'

import Layout from '../Layout'

import { OptionsEditor, type OptionInput } from '@/components/OptionsEditor'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

type Values = {
  event: string;
  description: string;
  end_voting_at: string;
  options: OptionInput[];
};

interface EditProps {
  poll: { id: string; name: string; path: string };
  values: Values;
  submit_path: string;
  admin_path: string;
  time_zone: string;
  errors?: Record<string, string>;
  new_poll_path?: string;
  debug?: string;
}

function FieldError({ message }: { message?: string }) {
  return message ? <p className="text-sm font-medium text-destructive">{message}</p> : null
}

export default function Edit({ poll, values, submit_path, admin_path, time_zone, errors = {}, new_poll_path, debug }: EditProps) {
  const [form, setForm] = useState<Values>(values)
  const [processing, setProcessing] = useState(false)

  const set = <K extends keyof Values>(key: K, value: Values[K]) => setForm(current => ({ ...current, [key]: value }))

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault()
    router.patch(submit_path, { poll: form }, {
      onStart: () => setProcessing(true),
      onFinish: () => setProcessing(false),
    })
  }

  return (
    <Layout new_poll_path={new_poll_path} debug={debug}>
      <Head title={`Edit ${poll.name}`} />
      <form onSubmit={handleSubmit} className="mx-auto max-w-4xl space-y-6">
        <div>
          <p className="text-sm text-muted-foreground">Organizer page</p>
          <h1 className="text-2xl font-bold">Edit poll</h1>
        </div>

        {errors.base && <FieldError message={errors.base} />}

        <div className="space-y-2">
          <Label htmlFor="event">Event</Label>
          <Input id="event" value={form.event} onChange={e => set('event', e.target.value)} />
          <FieldError message={errors.event} />
        </div>

        <div className="space-y-2">
          <Label htmlFor="description">Description</Label>
          <textarea
            id="description"
            value={form.description}
            onChange={e => set('description', e.target.value)}
            className="flex min-h-[100px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm"
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="end_voting_at">Voting deadline</Label>
          <Input
            id="end_voting_at"
            type="date"
            className="w-[200px]"
            value={form.end_voting_at}
            onChange={e => set('end_voting_at', e.target.value)}
          />
          <p className="text-xs text-muted-foreground">Voting closes at 11:59 PM on this day ({time_zone}).</p>
          <FieldError message={errors.end_voting_at} />
        </div>

        <div className="space-y-2">
          <Label>Dates and times</Label>
          <p className="text-xs text-muted-foreground">
            Removing a date deletes the answers for it. People who already voted can add answers for new dates.
          </p>
          <FieldError message={errors.options} />
          <OptionsEditor value={form.options} onChange={options => set('options', options)} hasError={!!errors.options} />
        </div>

        <div className="flex justify-end gap-3">
          <Link href={admin_path}>
            <Button type="button" variant="ghost">Cancel</Button>
          </Link>
          <Button type="submit" disabled={processing}>{processing ? 'Saving...' : 'Save changes'}</Button>
        </div>
      </form>
    </Layout>
  )
}
