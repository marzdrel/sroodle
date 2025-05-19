import * as React from "react"
import { useState } from "react"
import { format } from "date-fns"
import { Calendar } from "@/components/ui/calendar"
import { Button } from "@/components/ui/button"
import { X } from "lucide-react"
import { cn } from "@/lib/utils"

interface DateSelectorProps {
  onChange?: (dates: Date[]) => void
  initialDates?: Date[]
  className?: string
  hasError?: boolean
}

export function DateSelector({
  onChange,
  initialDates = [],
  className,
  hasError = false
}: DateSelectorProps) {
  const [selectedDates, setSelectedDates] = useState<Date[]>(initialDates)

  const handleRemoveDate = (dateToRemove: Date) => {
    const newSelectedDates = selectedDates.filter(
      (date) => format(date, 'yyyy-MM-dd') !== format(dateToRemove, 'yyyy-MM-dd')
    )
    setSelectedDates(newSelectedDates)
    onChange?.(newSelectedDates)
  }

  return (
    <div className={cn("flex flex-col md:flex-row gap-6", className)}>
      <div className="flex justify-center items-center md:justify-start md:w-auto">
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
          className={cn(
            "rounded-md border",
            hasError && "border-destructive"
          )}
        />
      </div>
      <div className="md:flex-1">
        <div className={cn(
          "border rounded-md p-4 h-full",
          hasError && "border-destructive"
        )}>
          <h3 className="text-lg font-medium mb-3">Selected Dates</h3>
          {selectedDates.length === 0 ? (
            <p className="text-muted-foreground text-sm">
              No dates selected. Click on the calendar to select dates for your event.
            </p>
          ) : (
            <div className="space-y-2 max-h-[280px] overflow-y-auto">
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