import { registerWebModule, NativeModule } from 'expo';

import { ExpoVideoToAudioModuleEvents, ExpoVideoToAudioOptions } from './ExpoVideoToAudio.types';

class ExpoVideoToAudioModule extends NativeModule<ExpoVideoToAudioModuleEvents> {
  extractAudio(options: ExpoVideoToAudioOptions): Promise<{ output_file: string }> {
   throw new Error('not implemented');
  }
}

export default registerWebModule(ExpoVideoToAudioModule);
