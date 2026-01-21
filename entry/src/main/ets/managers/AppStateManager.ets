import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { MenuItem, CartItem } from '../models/MenuItem';
import { Order, Address } from '../models/Order';

interface MenuItemData {
  itemId: number;
  name: string;
  price: number;
  category: string;
  stock: number;
}

interface CartItemData {
  menuItem: MenuItemData;
  quantity: number;
}

/**
 * 应用状态管理类
 */
@Observed
export class AppStateManager {
  private static instance: AppStateManager;

  // 购物车状态
  cartItems: CartItem[] = [];
  totalPrice: number = 0;
  totalQuantity: number = 0;

  // 当前选中的地址
  selectedAddress: Address | null = null;

  // 菜品分类
  categories: string[] = ['热菜', '汤类', '主食', '饮料'];

  // 偏好设置存储
  private preferences: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): AppStateManager {
    if (!AppStateManager.instance) {
      AppStateManager.instance = new AppStateManager();
    }
    return AppStateManager.instance;
  }

  /**
   * 初始化（需要在入口页面传入context调用一次）
   */
  async init(context: common.BaseContext): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, { name: 'restaurant_app' });
      await this.loadCartFromStorage();
    } catch (error) {
      console.error('Failed to initialize app state:', error);
    }
  }

  /**
   * 从本地存储加载购物车数据
   */
  private async loadCartFromStorage(): Promise<void> {
    if (!this.preferences) return;

    try {
      const cartDataStr = await this.preferences.get('cart_items', '');
      if (cartDataStr) {
        try {
          const cartData: CartItemData[] = JSON.parse(cartDataStr as string);
          this.cartItems = cartData.map((item) => {
            const menuItem = new MenuItem(
              item.menuItem.itemId,
              item.menuItem.name,
              item.menuItem.price,
              item.menuItem.category,
              item.menuItem.stock
            );
            return new CartItem(menuItem, item.quantity);
          });
          this.updateCartSummary();
        } catch (parseError) {
          console.error('Failed to parse cart data:', parseError);
          // 清空损坏的数据
          await this.preferences.put('cart_items', '');
        }
      }
    } catch (error) {
      console.error('Failed to load cart from storage:', error);
    }
  }

  /**
   * 保存购物车数据到本地存储
   */
  private async saveCartToStorage(): Promise<void> {
    if (!this.preferences) return;

    try {
      const cartData: CartItemData[] = this.cartItems.map((item: CartItem): CartItemData => ({
        menuItem: {
          itemId: item.menuItem.itemId,
          name: item.menuItem.name,
          price: item.menuItem.price,
          category: item.menuItem.category,
          stock: item.menuItem.stock
        },
        quantity: item.quantity
      }));
      await this.preferences.put('cart_items', JSON.stringify(cartData));
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save cart to storage:', error);
    }
  }

  /**
   * 添加菜品到购物车
   */
  addToCart(menuItem: MenuItem, quantity: number = 1): void {
    const existingItem = this.cartItems.find(item => item.menuItem.itemId === menuItem.itemId);

    if (existingItem) {
      // 如果已存在，增加数量
      existingItem.quantity += quantity;
    } else {
      // 如果不存在，添加新项
      this.cartItems.push(new CartItem(menuItem, quantity));
    }

    this.updateCartSummary();
    this.saveCartToStorage();
  }

  /**
   * 从购物车移除菜品
   */
  removeFromCart(itemId: number): void {
    const index = this.cartItems.findIndex(item => item.menuItem.itemId === itemId);
    if (index !== -1) {
      this.cartItems.splice(index, 1);
      this.updateCartSummary();
      this.saveCartToStorage();
    }
  }

  /**
   * 更新购物车中菜品的数量
   */
  updateCartItemQuantity(itemId: number, quantity: number): void {
    const item = this.cartItems.find(item => item.menuItem.itemId === itemId);
    if (item) {
      if (quantity <= 0) {
        this.removeFromCart(itemId);
      } else {
        item.quantity = quantity;
        this.updateCartSummary();
        this.saveCartToStorage();
      }
    }
  }

  /**
   * 清空购物车
   */
  clearCart(): void {
    this.cartItems = [];
    this.updateCartSummary();
    this.saveCartToStorage();
  }

  /**
   * 更新购物车汇总信息
   */
  private updateCartSummary(): void {
    this.totalQuantity = this.cartItems.reduce((sum, item) => sum + item.quantity, 0);
    this.totalPrice = this.cartItems.reduce((sum, item) => sum + item.getSubtotal(), 0);
  }

  /**
   * 获取购物车中的菜品数量
   */
  getCartItemCount(itemId: number): number {
    const item = this.cartItems.find(item => item.menuItem.itemId === itemId);
    return item ? item.quantity : 0;
  }

  /**
   * 检查购物车是否为空
   */
  isCartEmpty(): boolean {
    return this.cartItems.length === 0;
  }

  /**
   * 获取购物车中所有菜品的ID和数量映射
   */
  getCartItemsMap(): Map<number, number> {
    const itemsMap = new Map<number, number>();
    this.cartItems.forEach(item => {
      itemsMap.set(item.menuItem.itemId, item.quantity);
    });
    return itemsMap;
  }

  /**
   * 设置选中的地址
   */
  setSelectedAddress(address: Address): void {
    this.selectedAddress = address;
  }

  /**
   * 生成唯一订单号
   */
  generateOrderId(): string {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    return `ORDER${timestamp}${random}`;
  }

  /**
   * 获取当前时间字符串
   */
  getCurrentTimeString(): string {
    const now = new Date();
    return now.toISOString();
  }
}