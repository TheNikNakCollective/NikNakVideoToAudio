import { NativeModule, requireNativeModule } from 'expo';

import { ExpoVideoToAudioModuleEvents } from './ExpoVideoToAudio.types';

declare class ExpoVideoToAudioModule extends NativeModule<ExpoVideoToAudioModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoVideoToAudioModule>('ExpoVideoToAudio');
