import { SheetMusic } from '../types';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Music, User, Calendar } from 'lucide-react';

interface SheetMusicCardProps {
  sheetMusic: SheetMusic;
}

export function SheetMusicCard({ sheetMusic }: SheetMusicCardProps) {
  const formattedDate = new Date(sheetMusic.scannedAt).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      <div className="aspect-[3/4] overflow-hidden bg-muted">
        <ImageWithFallback
          src={sheetMusic.imageUrl}
          alt={`${sheetMusic.title} by ${sheetMusic.composer}`}
          className="w-full h-full object-cover"
        />
      </div>
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-2">
          <CardTitle className="line-clamp-1">{sheetMusic.title}</CardTitle>
          <Badge variant={sheetMusic.source === 'scan' ? 'default' : 'secondary'}>
            {sheetMusic.source}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-2">
        <div className="flex items-center gap-2 text-muted-foreground">
          <User className="h-4 w-4" />
          <span className="line-clamp-1">{sheetMusic.composer}</span>
        </div>
        <div className="flex items-center gap-2 text-muted-foreground">
          <Calendar className="h-4 w-4" />
          <span>{formattedDate}</span>
        </div>
      </CardContent>
    </Card>
  );
}
