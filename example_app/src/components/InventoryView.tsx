import { SheetMusic } from '../types';
import { SheetMusicCard } from './SheetMusicCard';
import { Input } from './ui/input';
import { Search } from 'lucide-react';

interface InventoryViewProps {
  inventory: SheetMusic[];
  searchQuery: string;
  onSearchChange: (query: string) => void;
}

export function InventoryView({ inventory, searchQuery, onSearchChange }: InventoryViewProps) {
  const filteredInventory = inventory.filter(item => 
    item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    item.composer.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="p-4 md:p-6">
      <div className="mb-6">
        <h2 className="mb-4">Browse Inventory</h2>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search by title or composer..."
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      {filteredInventory.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <p>No sheet music found</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredInventory.map(item => (
            <SheetMusicCard key={item.id} sheetMusic={item} />
          ))}
        </div>
      )}
    </div>
  );
}
