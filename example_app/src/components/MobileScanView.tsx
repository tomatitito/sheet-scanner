import { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Camera, Music, User, Loader2 } from 'lucide-react';
import { ScanMode, SheetMusic } from '../types';

interface MobileScanViewProps {
  onScanComplete: (sheetMusic: SheetMusic) => void;
}

export function MobileScanView({ onScanComplete }: MobileScanViewProps) {
  const [isScanning, setIsScanning] = useState(false);
  const [scanMode, setScanMode] = useState<ScanMode | null>(null);

  const handleScan = async (mode: ScanMode) => {
    setScanMode(mode);
    setIsScanning(true);

    // Simulate scanning process
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Mock scan result
    const mockResults = {
      full: {
        title: 'Clair de Lune',
        composer: 'Claude Debussy'
      },
      composer: {
        title: 'Unknown',
        composer: 'Wolfgang Amadeus Mozart'
      },
      title: {
        title: 'Symphony No. 5',
        composer: 'Unknown'
      }
    };

    const result = mockResults[mode];
    const newSheet: SheetMusic = {
      id: Date.now().toString(),
      title: result.title,
      composer: result.composer,
      imageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=400&h=500&fit=crop',
      scannedAt: new Date(),
      source: 'scan'
    };

    onScanComplete(newSheet);
    setIsScanning(false);
    setScanMode(null);
  };

  return (
    <div className="p-4 space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Scan Sheet Music</CardTitle>
          <CardDescription>
            Choose what information you want to scan from your sheet music
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <Button
            onClick={() => handleScan('full')}
            disabled={isScanning}
            className="w-full h-auto py-4"
            size="lg"
          >
            {isScanning && scanMode === 'full' ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Scanning...
              </>
            ) : (
              <>
                <Camera className="mr-2 h-5 w-5" />
                Scan Full Page
              </>
            )}
          </Button>

          <Button
            onClick={() => handleScan('composer')}
            disabled={isScanning}
            className="w-full h-auto py-4"
            variant="outline"
            size="lg"
          >
            {isScanning && scanMode === 'composer' ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Scanning...
              </>
            ) : (
              <>
                <User className="mr-2 h-5 w-5" />
                Scan Composer Only
              </>
            )}
          </Button>

          <Button
            onClick={() => handleScan('title')}
            disabled={isScanning}
            className="w-full h-auto py-4"
            variant="outline"
            size="lg"
          >
            {isScanning && scanMode === 'title' ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Scanning...
              </>
            ) : (
              <>
                <Music className="mr-2 h-5 w-5" />
                Scan Title Only
              </>
            )}
          </Button>
        </CardContent>
      </Card>

      {isScanning && (
        <Card className="bg-muted">
          <CardContent className="pt-6">
            <div className="text-center space-y-2">
              <Loader2 className="h-8 w-8 animate-spin mx-auto" />
              <p>Analyzing sheet music...</p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
