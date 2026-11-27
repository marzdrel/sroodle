export interface PollOptionTime {
  start: string;
  duration_minutes: number;
}

export interface FormattedOption {
  date: string;
  shortDate: string;
  weekday: string;
  time: string | null;
}

const ALL_DAY = 1440

// All-day options are stored as midnight UTC, so they are formatted in UTC
// to show the same calendar day everywhere. Timed options use the viewer's
// time zone.
export function formatOption({ start, duration_minutes }: PollOptionTime): FormattedOption {
  const startDate = new Date(start)
  const allDay = duration_minutes >= ALL_DAY
  const timeZone = allDay ? 'UTC' : undefined

  const date = startDate.toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', timeZone,
  })
  const shortDate = startDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', timeZone })
  const weekday = startDate.toLocaleDateString('en-US', { weekday: 'short', timeZone })

  if (allDay) {
    return { date, shortDate, weekday, time: null }
  }

  const endDate = new Date(startDate.getTime() + duration_minutes * 60000)
  const clock = (d: Date) => d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })

  return { date, shortDate, weekday, time: `${clock(startDate)} – ${clock(endDate)}` }
}

export function hasTimedOptions(options: PollOptionTime[]): boolean {
  return options.some(option => option.duration_minutes < ALL_DAY)
}

export function viewerTimeZone(): string {
  return Intl.DateTimeFormat().resolvedOptions().timeZone
}
