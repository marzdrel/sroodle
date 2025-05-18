import { Inertia } from '@inertiajs/inertia';
import { Link } from '@inertiajs/inertia';
import { InertiaApp } from '@inertiajs/inertia-react';
import { Button } from "@/components/ui/button";

export default function Layout({ children }) {
  return (
    <>
      <div className="min-h-full">
        <nav className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex">
                <div className="flex-shrink-0 flex items-center">
                <Button onClick={() => alert("Button clicked!")}>
                  Hello Shadcn Button
                </Button>


                </div>
                <div className="hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8">
                </div>
              </div>
            </div>
          </div>
        </nav>

        <div className="py-10">
          <main>
            <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">

              <div className="px-4 py-8 sm:px-0">
                <div className="bg-white rounded-lg h-96 p-3">
                  {children}
                </div>
              </div>

            </div>
          </main>
        </div>
      </div>
    </>
  )
}
