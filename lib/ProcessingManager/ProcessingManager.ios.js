// @flow

import { NativeModules } from 'react-native';
import { getActualSource } from '../utils';
const { VideoCompressModule, RNVideoTrimmer } = NativeModules;
import type {
  sourceType,
  trimOptions,
  previewMaxSize,
  format,
  compressOptions,
  cropOptions
} from './types';

export class ProcessingManager {
    static trim(source: sourceType, options: trimOptions = {}): Promise<string> {
      const actualSource: string = getActualSource(source);
      return new Promise((resolve, reject) => {
        RNVideoTrimmer.trim(actualSource, options, (err: Object<*>, output: string) => {
          if (err) {
            return reject(err);
          }
          return resolve(output);
        });
      });
    }

    static reverse(source: sourceType, options: trimOptions = {}): Promise<string> {
      return reject('not implemented');
    }

    static boomerang(source: sourceType, options: trimOptions = {}): Promise<string> {
      return reject('not implemented');
    }

  static getPreviewForSecond(
    source: sourceType,
    forSecond: ?number = 0,
    maximumSize: previewMaxSize,
    format: format
  ): Promise<string> {
    return reject('not implemented');
  }


  static getTrimmerPreviewImages(
      source: sourceType, 
      startTime: number, 
      endTime: number, 
      step: number, 
      maximumSize: previewMaxSize, 
      format: fromat
    ): Promise<*> {
    const actualSource: string = getActualSource(source)
    return new Promise((resolve, reject) => {
      RNVideoTrimmer.getTrimmerPreviewImages(actualSource, startTime, endTime, step, maximumSize, format,
        (err: Object<x>, res: any) => {
          if (err) {
            return reject(err);
          }
          return resolve(res)
        })
    })
  }


  static getVideoInfo(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return new Promise((resolve, reject) => {
      VideoCompressModule.getAssetInfo(actualSource, (err, info) => {
        if (err) {
          return reject(err);
        }
        return resolve(info);
      });
    });
  }

  static compress(source: sourceType, _options: compressOptions): Promise<string> {
    const options = { ..._options };
    const actualSource = getActualSource(source);
    return new Promise((resolve, reject) => {
      VideoCompressModule.compress(actualSource, options, (err, output) => {
        if (err) {
          return reject(err);
        }
        return resolve(output);
      });
    });
  }

  static crop(source: sourceType, options: cropOptions = {}): Promise<string> {
    return reject('not implemented');
  }

}
