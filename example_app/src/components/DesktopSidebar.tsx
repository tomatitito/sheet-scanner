import { Button } from './ui/button';
import { Upload, Library, Clock, Music } from 'lucide-react';
import { ViewMode } from '../types';

interface DesktopSidebarProps {
  currentView: ViewMode;
  onViewChange: (view: ViewMode) => void;
}

export function DesktopSidebar({ currentView, onViewChange }: DesktopSidebarProps) {
  return (
    <aside className="w-64 bg-muted/30 border-r min-h-screen p-4">
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-2">
          <Music className="h-6 w-6" />
          <h1 className="text-lg">Sheet Music Manager</h1>
        </div>
        <p className="text-muted-foreground">Desktop Version</p>
      </div>

      <nav className="space-y-2">
        <Button
          variant={currentView === 'scan' ? 'default' : 'ghost'}
          className="w-full justify-start"
          onClick={() => onViewChange('scan')}
        >
          <Upload className="mr-2 h-4 w-4" />
          Upload
        </Button>

        <Button
          variant={currentView === 'search' ? 'default' : 'ghost'}
          className="w-full justify-start"
          onClick={() => onViewChange('search')}
        >
          <Library className="mr-2 h-4 w-4" />
          Search Inventory
        </Button>

        <Button
          variant={currentView === 'inventory' ? 'default' : 'ghost'}
          className="w-full justify-start"
          onClick={() => onViewChange('inventory')}
        >
          <Library className="mr-2 h-4 w-4" />
          Browse All
        </Button>

        <Button
          variant={currentView === 'recent' ? 'default' : 'ghost'}
          className="w-full justify-start"
          onClick={() => onViewChange('recent')}
        >
          <Clock className="mr-2 h-4 w-4" />
          Recent
        </Button>
      </nav>
    </aside>
  );
}
