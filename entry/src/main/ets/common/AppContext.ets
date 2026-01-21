import { common } from '@kit.AbilityKit';

let appContext: common.BaseContext | null = null;

/**
 * 设置应用全局Context（由Ability在启动时注入）
 */
export function setAppContext(context: common.BaseContext): void {
  appContext = context;
}

/**
 * 获取应用全局Context
 */
export function getAppContext(): common.BaseContext {
  if (appContext === null) {
    throw new Error('AppContext is not initialized');
  }
  return appContext;
}
