import { format, parseISO } from 'date-fns'
import { Plus, X } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { cn } from '@/lib/utils'

export type OptionInput = {
  date: string; // yyyy-MM-dd
  time: string; // HH:mm, or '' for all day
  duration_minutes: number;
};

interface OptionsEditorProps {
  value: OptionInput[];
  onChange: (options: OptionInput[]) => void;
  hasError?: boolean;
  className?: string;
}

export const ALL_DAY = 1440

export const DURATIONS: { minutes: number; label: string }[] = [
  { minutes: 30, label: '30 min' },
  { minutes: 60, label: '1 hour' },
  { minutes: 90, label: '1.5 hours' },
  { minutes: 120, label: '2 hours' },
  { minutes: 180, label: '3 hours' },
  { minutes: 240, label: '4 hours' },
  { minutes: 480, label: '8 hours' },
]

const DEFAULT_SLOT = { time: '18:00', duration_minutes: 60 }

function sortOptions(options: OptionInput[]) {
  return [...options].sort((a, b) =>
    a.date === b.date ? a.time.localeCompare(b.time) : a.date.localeCompare(b.date)
  )
}

// Pick days on the calendar, then keep each day "All day" or give it one or
// more time slots.
export function OptionsEditor({ value, onChange, hasError = false, className }: OptionsEditorProps) {
  const dates = Array.from(new Set(value.map(option => option.date))).sort()
  const selectedDays = dates.map(date => parseISO(date))

  const update = (options: OptionInput[]) => onChange(sortOptions(options))

  const handleCalendar = (days: Date[] | undefined) => {
    const picked = (days || []).map(day => format(day, 'yyyy-MM-dd'))
    const kept = value.filter(option => picked.includes(option.date))
    const added = picked
      .filter(date => !dates.includes(date))
      .map(date => ({ date, time: '', duration_minutes: ALL_DAY }))

    update([...kept, ...added])
  }

  const replaceAt = (index: number, option: OptionInput | null) => {
    const sorted = sortOptions(value)
    const next = option ? sorted.map((o, i) => (i === index ? option : o)) : sorted.filter((_, i) => i !== index)
    update(next)
  }

  const addSlot = (date: string) => {
    const sameDay = value.filter(option => option.date === date)

    if (sameDay.length === 1 && sameDay[0].time === '') {
      update([...value.filter(option => option.date !== date), { date, ...DEFAULT_SLOT }])
    } else {
      const usedTimes = sameDay.map(option => option.time)
      const time = ['18:00', '12:00', '09:00', '15:00', '20:00'].find(t => !usedTimes.includes(t)) || '10:00'
      update([...value, { date, time, duration_minutes: DEFAULT_SLOT.duration_minutes }])
    }
  }

  const sorted = sortOptions(value)

  return (
    <div className={cn('flex flex-col gap-6 md:flex-row', className)}>
      <div className="flex items-center justify-center md:w-auto md:justify-start">
        <Calendar
          mode="multiple"
          selected={selectedDays}
          onSelect={handleCalendar}
          disabled={(date: Date) => date < new Date(new Date().setHours(0, 0, 0, 0))}
          className={cn('rounded-md border', hasError && 'border-destructive')}
        />
      </div>
      <div className="md:flex-1">
        <div className={cn('h-full rounded-md border p-4', hasError && 'border-destructive')}>
          <h3 className="mb-3 text-lg font-medium">Selected dates</h3>
          {dates.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No dates selected. Click on the calendar to select dates for your event.
            </p>
          ) : (
            <div className="max-h-[360px] space-y-3 overflow-y-auto">
              {dates.map(date => (
                <div key={date} className="rounded-md bg-accent/50 p-3" data-testid={`day-${date}`}>
                  <div className="mb-2 flex items-center justify-between">
                    <span className="text-sm font-medium">{format(parseISO(date), 'EEEE, MMMM d, yyyy')}</span>
                    <Button type="button" variant="ghost" size="sm" onClick={() => addSlot(date)}>
                      <Plus className="mr-1 h-4 w-4" /> Add time
                    </Button>
                  </div>
                  <ul className="space-y-2">
                    {sorted.map((option, index) =>
                      option.date !== date ? null : (
                        <li key={`${option.date}-${option.time}-${index}`} className="flex flex-wrap items-center gap-2">
                          {option.time === '' ? (
                            <span className="text-sm text-muted-foreground">All day</span>
                          ) : (
                            <>
                              <input
                                type="time"
                                aria-label="Start time"
                                value={option.time}
                                step={900}
                                onChange={e => e.target.value && replaceAt(index, { ...option, time: e.target.value })}
                                className="h-8 rounded-md border bg-background px-2 text-sm"
                              />
                              <select
                                aria-label="Duration"
                                value={option.duration_minutes}
                                onChange={e => replaceAt(index, { ...option, duration_minutes: Number(e.target.value) })}
                                className="h-8 rounded-md border bg-background px-2 text-sm"
                              >
                                {DURATIONS.map(d => (
                                  <option key={d.minutes} value={d.minutes}>{d.label}</option>
                                ))}
                              </select>
                            </>
                          )}
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            className="h-7 w-7 p-0 text-muted-foreground"
                            onClick={() => replaceAt(index, null)}
                          >
                            <X className="h-4 w-4" />
                            <span className="sr-only">Remove</span>
                          </Button>
                        </li>
                      )
                    )}
                  </ul>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
