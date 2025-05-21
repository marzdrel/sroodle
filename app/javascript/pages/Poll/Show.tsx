import { Head, Link } from '@inertiajs/react'
import React from 'react'

import Layout from '../Layout'

import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'

interface Participant {
  id: number;
  name: string;
  email: string;
  avatarUrl?: string;
  responses: {
    date: string;
    preference: 'yes' | 'maybe' | 'no';
  }[];
}

interface PollDate {
  date: string;
  responses: {
    yes: number;
    maybe: number;
    no: number;
  };
}

interface Poll {
  id: string;
  eid: string;
  name: string;
  event: string;
  description: string;
  creator: {
    email: string;
    name: string;
  };
  created_at: string;
  dates: PollDate[];
}

interface ShowProps {
  poll: Poll;
  participants?: Participant[];
}

export default function Show({ poll, participants = [] }: ShowProps) {
  // Convert date strings to Date objects for the calendar
  const pollDates = poll.dates.map(d => new Date(d.date));

  // Mock data for best dates (this would be calculated based on responses)
  const bestDates = pollDates.slice(0, 2);

  // Functions to get preference counts
  const getYesCount = (date: string) => {
    const pollDate = poll.dates.find(d => d.date === date);
    return pollDate?.responses.yes || 0;
  };

  const getMaybeCount = (date: string) => {
    const pollDate = poll.dates.find(d => d.date === date);
    return pollDate?.responses.maybe || 0;
  };

  return (
    <Layout>
      <Head title={`${poll.event} - Poll`} />
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-between items-start">
            <div>
              <h1 className="text-3xl font-bold">{poll.event}</h1>
              <p className="text-sm text-muted-foreground mt-1">
                Created by {poll.creator.name} ({poll.creator.email})
              </p>
              <p className="text-sm text-muted-foreground">
                Created on {new Date(poll.created_at).toLocaleDateString()}
              </p>
            </div>
            <div className="flex space-x-3">
              <Button variant="outline">Share Poll</Button>
              <Link href="/polls">
                <Button variant="ghost">Back to Polls</Button>
              </Link>
            </div>
          </div>

          {/* Description */}
          <div className="mt-6 p-4 bg-muted/50 rounded-lg">
            <h2 className="text-lg font-medium mb-2">Description</h2>
            <p>{poll.description}</p>
          </div>
        </div>

        <div className="space-y-6">
          {/* Best dates summary */}
          <div className="p-6 border rounded-lg bg-card">
            <h2 className="text-lg font-medium mb-4">Best Dates</h2>
            {bestDates.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {bestDates.map((date, i) => (
                  <div key={i} className="flex justify-between items-center p-4 bg-muted/50 rounded-md">
                    <div>
                      <span className="font-medium">{date.toLocaleDateString('en-US', { weekday: 'long' })}</span>
                      <span className="ml-2">{date.toLocaleDateString()}</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Badge className="bg-green-100 text-green-800">
                        {getYesCount(date.toISOString().split('T')[0])} Yes
                      </Badge>
                      <Badge className="bg-yellow-100 text-yellow-800">
                        {getMaybeCount(date.toISOString().split('T')[0])} Maybe
                      </Badge>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground text-sm">No responses yet</p>
            )}
          </div>


          {/* Responses table */}
          <div className="p-6 border rounded-lg bg-card overflow-x-auto">
            <h2 className="text-lg font-medium mb-4">All Responses</h2>
            {participants.length > 0 ? (
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left pb-2 font-medium">Participant</th>
                    {poll.dates.map((date, i) => (
                      <th key={i} className="px-2 text-center pb-2 font-medium">
                        <div className="whitespace-nowrap">{new Date(date.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</div>
                        <div className="text-xs text-muted-foreground whitespace-nowrap">{new Date(date.date).toLocaleDateString('en-US', { weekday: 'short' })}</div>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {participants.map((participant) => (
                    <tr key={participant.id} className="border-b">
                      <td className="py-3">
                        <div className="flex items-center space-x-2">
                          <Avatar className="h-8 w-8">
                            <AvatarImage src={participant.avatarUrl} alt={participant.name} />
                            <AvatarFallback>{participant.name.substring(0, 2).toUpperCase()}</AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium">{participant.name}</div>
                            <div className="text-xs text-muted-foreground">{participant.email}</div>
                          </div>
                        </div>
                      </td>
                      {poll.dates.map((date, i) => {
                        const response = participant.responses.find(r => r.date === date.date);
                        let bgColor = 'bg-gray-100';
                        let content = '—';

                        if (response) {
                          if (response.preference === 'yes') {
                            bgColor = 'bg-green-100';
                            content = '✓';
                          } else if (response.preference === 'maybe') {
                            bgColor = 'bg-yellow-100';
                            content = '?';
                          } else {
                            bgColor = 'bg-red-100';
                            content = '✗';
                          }
                        }

                        return (
                          <td key={i} className="text-center">
                            <div className={`mx-auto my-1 h-8 w-8 flex items-center justify-center rounded-full ${bgColor}`}>
                              {content}
                            </div>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className="text-center py-10">
                <p className="text-muted-foreground">No responses yet</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  )
}