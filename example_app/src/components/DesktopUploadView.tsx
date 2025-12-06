import { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Upload, Loader2 } from 'lucide-react';
import { SheetMusic } from '../types';

interface DesktopUploadViewProps {
  onUploadComplete: (sheetMusic: SheetMusic) => void;
}

export function DesktopUploadView({ onUploadComplete }: DesktopUploadViewProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [title, setTitle] = useState('');
  const [composer, setComposer] = useState('');

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsUploading(true);

    // Simulate upload process
    await new Promise(resolve => setTimeout(resolve, 1500));

    const newSheet: SheetMusic = {
      id: Date.now().toString(),
      title: title || 'Untitled',
      composer: composer || 'Unknown',
      imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=400&h=500&fit=crop',
      scannedAt: new Date(),
      source: 'upload'
    };

    onUploadComplete(newSheet);
    setIsUploading(false);
    setTitle('');
    setComposer('');
  };

  return (
    <div className="p-6">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle>Upload Sheet Music</CardTitle>
          <CardDescription>
            Upload a PDF or image of your sheet music and enter its details
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleUpload} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="file">Sheet Music File</Label>
              <div className="border-2 border-dashed rounded-lg p-8 text-center hover:border-primary transition-colors cursor-pointer">
                <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                <Input
                  id="file"
                  type="file"
                  accept="image/*,.pdf"
                  className="hidden"
                />
                <Label htmlFor="file" className="cursor-pointer">
                  <p className="mb-2">Click to upload or drag and drop</p>
                  <p className="text-muted-foreground">PDF, PNG, JPG up to 10MB</p>
                </Label>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                placeholder="Enter sheet music title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="composer">Composer</Label>
              <Input
                id="composer"
                placeholder="Enter composer name"
                value={composer}
                onChange={(e) => setComposer(e.target.value)}
                required
              />
            </div>

            <Button type="submit" className="w-full" disabled={isUploading}>
              {isUploading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Uploading...
                </>
              ) : (
                <>
                  <Upload className="mr-2 h-4 w-4" />
                  Upload Sheet Music
                </>
              )}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
