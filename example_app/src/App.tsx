import { useState, useEffect } from 'react';
import { MobileScanView } from './components/MobileScanView';
import { DesktopUploadView } from './components/DesktopUploadView';
import { InventoryView } from './components/InventoryView';
import { RecentScansView } from './components/RecentScansView';
import { MobileNavigation } from './components/MobileNavigation';
import { DesktopSidebar } from './components/DesktopSidebar';
import { SheetMusic, ViewMode } from './types';
import { mockInventory } from './utils/mockData';
import { Music } from 'lucide-react';

export default function App() {
  const [isMobile, setIsMobile] = useState(false);
  const [currentView, setCurrentView] = useState<ViewMode>('scan');
  const [inventory, setInventory] = useState<SheetMusic[]>(mockInventory);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const handleScanComplete = (sheetMusic: SheetMusic) => {
    setInventory(prev => [sheetMusic, ...prev]);
    setCurrentView('recent');
  };

  const handleUploadComplete = (sheetMusic: SheetMusic) => {
    setInventory(prev => [sheetMusic, ...prev]);
    setCurrentView('recent');
  };

  const renderContent = () => {
    if (currentView === 'scan') {
      return isMobile ? (
        <MobileScanView onScanComplete={handleScanComplete} />
      ) : (
        <DesktopUploadView onUploadComplete={handleUploadComplete} />
      );
    }

    if (currentView === 'search' || currentView === 'inventory') {
      return (
        <InventoryView
          inventory={inventory}
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
        />
      );
    }

    if (currentView === 'recent') {
      return <RecentScansView recentScans={inventory} />;
    }

    return null;
  };

  if (isMobile) {
    return (
      <div className="min-h-screen pb-20 bg-background">
        <header className="sticky top-0 z-40 bg-background border-b p-4">
          <div className="flex items-center gap-2">
            <Music className="h-6 w-6" />
            <div>
              <h1 className="text-lg">Sheet Music Scanner</h1>
              <p className="text-muted-foreground">Mobile Version</p>
            </div>
          </div>
        </header>

        <main>{renderContent()}</main>

        <MobileNavigation
          currentView={currentView}
          onViewChange={setCurrentView}
        />
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-background">
      <DesktopSidebar
        currentView={currentView}
        onViewChange={setCurrentView}
      />

      <main className="flex-1 overflow-auto">
        {renderContent()}
      </main>
    </div>
  );
}
