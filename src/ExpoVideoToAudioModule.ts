import { NativeModule, requireNativeModule } from 'expo';
import { ExpoVideoToAudioModuleEvents, ExpoVideoToAudioOptions } from './ExpoVideoToAudio.types';

declare class ExpoVideoToAudioModule extends NativeModule<ExpoVideoToAudioModuleEvents> {
  extractAudio(options: ExpoVideoToAudioOptions): Promise<{ output_file: string }>;
}


const ExpoVideoToAudio = requireNativeModule<ExpoVideoToAudioModule>('ExpoVideoToAudio');

export default ExpoVideoToAudio
