export interface SheetMusic {
  id: string;
  title: string;
  composer: string;
  imageUrl: string;
  scannedAt: Date;
  source: 'scan' | 'upload';
}

export type ScanMode = 'full' | 'composer' | 'title';

export type ViewMode = 'scan' | 'inventory' | 'recent' | 'search';
