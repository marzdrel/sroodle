import * as React from "react"
import { useState, useRef, useEffect } from "react"
import { format } from "date-fns"
import { Calendar } from "@/components/ui/calendar"
import { Button } from "@/components/ui/button"
import { X } from "lucide-react"
import { cn } from "@/lib/utils"

interface DateSelectorProps {
  onChange?: (dates: Date[]) => void
  initialDates?: Date[]
  className?: string
}

export function DateSelector({
  onChange,
  initialDates = [],
  className
}: DateSelectorProps) {
  const [selectedDates, setSelectedDates] = useState<Date[]>(initialDates)
  const calendarRef = useRef<HTMLDivElement>(null)
  const datesContainerRef = useRef<HTMLDivElement>(null)
  const datesListRef = useRef<HTMLDivElement>(null)
  const [maxHeight, setMaxHeight] = useState<number | undefined>(undefined)

  // Update max height when calendar size changes or on window resize
  useEffect(() => {
    const updateMaxHeight = () => {
      if (calendarRef.current && datesContainerRef.current && datesListRef.current) {
        const calendarHeight = calendarRef.current.getBoundingClientRect().height;
        const headerHeight = datesContainerRef.current.querySelector('h3')?.getBoundingClientRect().height || 0;
        const containerPadding = 32; // 2rem (p-4 = 1rem on top + 1rem on bottom)

        // Set max height for the dates list to make total container height equal to calendar
        const maxListHeight = calendarHeight - headerHeight - containerPadding;
        setMaxHeight(maxListHeight);
      }
    }

    // Initial calculation after a slight delay to ensure rendering is complete
    const timer = setTimeout(() => {
      updateMaxHeight();
    }, 100);

    // Add resize listener
    window.addEventListener('resize', updateMaxHeight);

    // Cleanup
    return () => {
      clearTimeout(timer);
      window.removeEventListener('resize', updateMaxHeight);
    }
  }, []);

  const handleRemoveDate = (dateToRemove: Date) => {
    const newSelectedDates = selectedDates.filter(
      (date) => format(date, 'yyyy-MM-dd') !== format(dateToRemove, 'yyyy-MM-dd')
    )
    setSelectedDates(newSelectedDates)
    onChange?.(newSelectedDates)
  }

  return (
    <div className={cn("flex flex-col md:flex-row gap-6", className)}>
      <div
        ref={calendarRef}
        className="flex justify-center items-center md:justify-start md:w-auto"
      >
        <Calendar
          mode="multiple"
          selected={selectedDates}
          onSelect={(value) => {
            if (Array.isArray(value)) {
              setSelectedDates(value);
              onChange?.(value);
            }
          }}
          disabled={(date) => date < new Date(new Date().setHours(0, 0, 0, 0))}
          className="rounded-md border"
        />
      </div>
      <div className="md:flex-1 md:self-start">
        <div
          ref={datesContainerRef}
          className="border rounded-md p-4"
        >
          <h3 className="text-lg font-medium mb-3">Selected Dates</h3>
          {selectedDates.length === 0 ? (
            <p className="text-muted-foreground text-sm">
              No dates selected. Click on the calendar to select dates for your event.
            </p>
          ) : (
            <div
              ref={datesListRef}
              className="space-y-2 overflow-y-auto pr-1"
              style={{
                maxHeight: maxHeight ? `${maxHeight}px` : '220px'
              }}
            >
              {selectedDates
                .sort((a, b) => a.getTime() - b.getTime())
                .map((date) => (
                  <div
                    key={date.toISOString()}
                    className="flex items-center justify-between bg-accent/50 p-3 rounded-md"
                  >
                    <span className="text-sm font-medium">
                      {format(date, 'EEEE, MMMM d, yyyy')}
                    </span>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="h-7 w-7 p-0 text-muted-foreground"
                      onClick={() => handleRemoveDate(date)}
                    >
                      <X className="h-4 w-4" />
                      <span className="sr-only">Remove</span>
                    </Button>
                  </div>
                ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}