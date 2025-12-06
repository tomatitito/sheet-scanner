import { SheetMusic } from '../types';
import { SheetMusicCard } from './SheetMusicCard';

interface RecentScansViewProps {
  recentScans: SheetMusic[];
}

export function RecentScansView({ recentScans }: RecentScansViewProps) {
  const sortedScans = [...recentScans].sort((a, b) => 
    new Date(b.scannedAt).getTime() - new Date(a.scannedAt).getTime()
  );

  return (
    <div className="p-4 md:p-6">
      <h2 className="mb-6">Recent Scans</h2>

      {sortedScans.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <p>No recent scans</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {sortedScans.map(item => (
            <SheetMusicCard key={item.id} sheetMusic={item} />
          ))}
        </div>
      )}
    </div>
  );
}
