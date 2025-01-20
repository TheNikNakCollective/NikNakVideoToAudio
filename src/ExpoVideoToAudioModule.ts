import { NativeModule, requireNativeModule } from 'expo';

import { ExpoVideoToAudioModuleEvents, ExtractAudioOptions } from './ExpoVideoToAudio.types';

declare class ExpoVideoToAudioModule extends NativeModule<ExpoVideoToAudioModuleEvents> {
  extractAudio(options: ExtractAudioOptions): Promise<{}>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoVideoToAudioModule>('ExpoVideoToAudio');
