import { SheetMusic } from '../types';

export const mockInventory: SheetMusic[] = [
  {
    id: '1',
    title: 'Moonlight Sonata',
    composer: 'Ludwig van Beethoven',
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-28'),
    source: 'scan'
  },
  {
    id: '2',
    title: 'Für Elise',
    composer: 'Ludwig van Beethoven',
    imageUrl: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-25'),
    source: 'scan'
  },
  {
    id: '3',
    title: 'Nocturne in E-flat Major',
    composer: 'Frédéric Chopin',
    imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-20'),
    source: 'upload'
  },
  {
    id: '4',
    title: 'The Four Seasons',
    composer: 'Antonio Vivaldi',
    imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-15'),
    source: 'scan'
  },
  {
    id: '5',
    title: 'Canon in D',
    composer: 'Johann Pachelbel',
    imageUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-10'),
    source: 'upload'
  },
  {
    id: '6',
    title: 'Prelude in C Major',
    composer: 'Johann Sebastian Bach',
    imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400&h=500&fit=crop',
    scannedAt: new Date('2024-11-05'),
    source: 'scan'
  }
];
