
interface DevelopmentUIProps {
  debug?: string;
}

export default function DevelopmentUI({ debug }: DevelopmentUIProps) {
  if (!debug) {
    return null
  }

  return (
    <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-4">
      <h3 className="text-sm font-medium text-yellow-800 mb-2">
        Development Debug Info
      </h3>
      <pre className="whitespace-pre-wrap overflow-auto max-h-96 text-xs bg-yellow-100 p-2 rounded w-full">
        {debug}
      </pre>
    </div>
  )
}
