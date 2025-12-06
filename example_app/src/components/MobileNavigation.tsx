import { Button } from './ui/button';
import { Camera, Library, Clock, Search } from 'lucide-react';
import { ViewMode } from '../types';

interface MobileNavigationProps {
  currentView: ViewMode;
  onViewChange: (view: ViewMode) => void;
}

export function MobileNavigation({ currentView, onViewChange }: MobileNavigationProps) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-background border-t z-50">
      <div className="grid grid-cols-4 gap-1 p-2">
        <Button
          variant={currentView === 'scan' ? 'default' : 'ghost'}
          className="flex flex-col h-auto py-2"
          onClick={() => onViewChange('scan')}
        >
          <Camera className="h-5 w-5 mb-1" />
          <span className="text-xs">Scan</span>
        </Button>

        <Button
          variant={currentView === 'search' ? 'default' : 'ghost'}
          className="flex flex-col h-auto py-2"
          onClick={() => onViewChange('search')}
        >
          <Search className="h-5 w-5 mb-1" />
          <span className="text-xs">Search</span>
        </Button>

        <Button
          variant={currentView === 'inventory' ? 'default' : 'ghost'}
          className="flex flex-col h-auto py-2"
          onClick={() => onViewChange('inventory')}
        >
          <Library className="h-5 w-5 mb-1" />
          <span className="text-xs">Inventory</span>
        </Button>

        <Button
          variant={currentView === 'recent' ? 'default' : 'ghost'}
          className="flex flex-col h-auto py-2"
          onClick={() => onViewChange('recent')}
        >
          <Clock className="h-5 w-5 mb-1" />
          <span className="text-xs">Recent</span>
        </Button>
      </div>
    </nav>
  );
}
