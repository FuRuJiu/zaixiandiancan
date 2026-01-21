import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { MenuItem, CartItem } from '../models/MenuItem';
import { Order, Address } from '../models/Order';

/**
 * 数据库管理类
 */
interface MenuItemData {
  item_id: number;
  name: string;
  price: number;
  category: string;
  stock: number;
}

interface MenuInsertData {
  item_id: number;
  name: string;
  price: number;
  category: string;
  stock: number;
}

interface OrderInsertData {
  order_id: string;
  items: string;
  total: number;
  address: string;
  create_time: string;
  status: string;
}

interface AddressInsertData {
  name: string;
  phone: string;
  address: string;
  is_default: number;
}

export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.BaseContext | null = null;
  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'restaurant.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  private constructor() {}

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  /**
   * 初始化数据库
   */
  async initDatabase(context: common.BaseContext): Promise<void> {
    try {
      // 获取数据库存储
      this.context = context;
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);
      await this.createTables();
      await this.initSampleData();
    } catch (error) {
      console.error('Database initialization failed:', error);
    }
  }

  /**
   * 创建表结构
   */
  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;

    // 创建菜品表
    const createMenuTable = `
      CREATE TABLE IF NOT EXISTS menu (
        item_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0
      )
    `;

    // 创建订单表
    const createOrderTable = `
      CREATE TABLE IF NOT EXISTS orders (
        order_id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        total REAL NOT NULL,
        address TEXT NOT NULL,
        create_time TEXT NOT NULL,
        status TEXT DEFAULT '待处理'
      )
    `;

    // 创建地址表
    const createAddressTable = `
      CREATE TABLE IF NOT EXISTS addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    `;

    await this.rdbStore.executeSql(createMenuTable);
    await this.rdbStore.executeSql(createOrderTable);
    await this.rdbStore.executeSql(createAddressTable);
  }

  /**
   * 初始化示例数据
   */
  private async initSampleData(): Promise<void> {
    if (!this.rdbStore) return;

    // 检查是否已有数据
    const result = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM menu');
    if (result.rowCount > 0 && result.goToFirstRow() && result.getDouble(0) > 0) {
      return; // 已初始化
    }

    // 插入示例菜品数据
    const sampleMenuItems: MenuItemData[] = [
      { item_id: 1, name: '宫保鸡丁', price: 28.0, category: '热菜', stock: 50 },
      { item_id: 2, name: '鱼香肉丝', price: 26.0, category: '热菜', stock: 40 },
      { item_id: 3, name: '麻婆豆腐', price: 22.0, category: '热菜', stock: 30 },
      { item_id: 4, name: '糖醋里脊', price: 32.0, category: '热菜', stock: 35 },
      { item_id: 5, name: '西红柿炒蛋', price: 18.0, category: '热菜', stock: 25 },
      { item_id: 6, name: '青菜豆腐汤', price: 12.0, category: '汤类', stock: 60 },
      { item_id: 7, name: '酸辣汤', price: 15.0, category: '汤类', stock: 45 },
      { item_id: 8, name: '玉米排骨汤', price: 28.0, category: '汤类', stock: 20 },
      { item_id: 9, name: '米饭', price: 3.0, category: '主食', stock: 100 },
      { item_id: 10, name: '馒头', price: 2.0, category: '主食', stock: 80 },
      { item_id: 11, name: '花卷', price: 2.5, category: '主食', stock: 70 },
      { item_id: 12, name: '可乐', price: 5.0, category: '饮料', stock: 90 },
      { item_id: 13, name: '雪碧', price: 5.0, category: '饮料', stock: 85 },
      { item_id: 14, name: '橙汁', price: 8.0, category: '饮料', stock: 40 },
      { item_id: 15, name: '酸奶', price: 6.0, category: '饮料', stock: 50 }
    ];

    for (const item of sampleMenuItems) {
      const values: relationalStore.ValuesBucket = {
        item_id: item.item_id,
        name: item.name,
        price: item.price,
        category: item.category,
        stock: item.stock
      };
      await this.rdbStore.insert('menu', values);
    }
  }

  /**
   * 获取所有菜品
   */
  async getAllMenuItems(): Promise<MenuItem[]> {
    if (!this.rdbStore) return [];

    const result = await this.rdbStore.querySql('SELECT * FROM menu ORDER BY category, item_id');
    const menuItems: MenuItem[] = [];

    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      menuItems.push(new MenuItem(
        result.getDouble(0), // item_id
        result.getString(1), // name
        result.getDouble(2), // price
        result.getString(3), // category
        result.getDouble(4)  // stock
      ));
    }

    return menuItems;
  }

  /**
   * 根据分类获取菜品
   */
  async getMenuItemsByCategory(category: string): Promise<MenuItem[]> {
    if (!this.rdbStore) return [];

    const result = await this.rdbStore.querySql('SELECT * FROM menu WHERE category = ? ORDER BY item_id', [category]);
    const menuItems: MenuItem[] = [];

    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      menuItems.push(new MenuItem(
        result.getDouble(0),
        result.getString(1),
        result.getDouble(2),
        result.getString(3),
        result.getDouble(4)
      ));
    }

    return menuItems;
  }

  /**
   * 根据ID获取菜品
   */
  async getMenuItemById(itemId: number): Promise<MenuItem | null> {
    if (!this.rdbStore) return null;

    const result = await this.rdbStore.querySql('SELECT * FROM menu WHERE item_id = ?', [itemId]);
    if (result.rowCount === 0) return null;

    result.goToFirstRow();
    return new MenuItem(
      result.getDouble(0),
      result.getString(1),
      result.getDouble(2),
      result.getString(3),
      result.getDouble(4)
    );
  }

  /**
   * 更新菜品库存
   */
  async updateMenuItemStock(itemId: number, newStock: number): Promise<void> {
    if (!this.rdbStore) return;

    await this.rdbStore.executeSql('UPDATE menu SET stock = ? WHERE item_id = ?', [newStock, itemId]);
  }

  /**
   * 批量更新库存（用于下单）
   */
  async updateStocks(items: Map<number, number>): Promise<void> {
    if (!this.rdbStore) return;

    const itemIds = items.keys();
    for (const itemId of itemIds) {
      const quantity = items.get(itemId);
      if (quantity !== undefined) {
        const currentItem = await this.getMenuItemById(itemId);
        if (currentItem && currentItem.stock >= quantity) {
          await this.updateMenuItemStock(itemId, currentItem.stock - quantity);
        } else {
          throw new Error(`菜品 ${itemId} 库存不足`);
        }
      }
    }
  }

  /**
   * 创建订单
   */
  async createOrder(order: Order): Promise<void> {
    if (!this.rdbStore) return;

    const orderData: relationalStore.ValuesBucket = {
      order_id: order.orderId,
      items: order.getItemsJson(),
      total: order.total,
      address: order.address,
      create_time: order.createTime,
      status: order.status
    };

    await this.rdbStore.insert('orders', orderData);
  }

  /**
   * 获取所有订单
   */
  async getAllOrders(): Promise<Order[]> {
    if (!this.rdbStore) return [];

    const result = await this.rdbStore.querySql('SELECT * FROM orders ORDER BY create_time DESC');
    const orders: Order[] = [];

    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      const items = Order.parseItemsFromJson(result.getString(1));
      orders.push(new Order(
        result.getString(0), // order_id
        items,
        result.getDouble(2), // total
        result.getString(3), // address
        result.getString(4), // create_time
        result.getString(5)  // status
      ));
    }

    return orders;
  }

  /**
   * 保存地址
   */
  async saveAddress(address: Address): Promise<void> {
    if (!this.rdbStore) return;

    // 如果设置为默认地址，先取消其他默认地址
    if (address.isDefault) {
      await this.rdbStore.executeSql('UPDATE addresses SET is_default = 0 WHERE is_default = 1');
    }

    const addressData: relationalStore.ValuesBucket = {
      name: address.name,
      phone: address.phone,
      address: address.address,
      is_default: address.isDefault ? 1 : 0
    };

    await this.rdbStore.insert('addresses', addressData);
  }

  /**
   * 获取所有地址
   */
  async getAllAddresses(): Promise<Address[]> {
    if (!this.rdbStore) return [];

    const result = await this.rdbStore.querySql('SELECT * FROM addresses ORDER BY is_default DESC, id DESC');
    const addresses: Address[] = [];

    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      addresses.push(new Address(
        result.getString(1), // name
        result.getString(2), // phone
        result.getString(3), // address
        result.getDouble(4) === 1 // is_default
      ));
    }

    return addresses;
  }

  /**
   * 获取默认地址
   */
  async getDefaultAddress(): Promise<Address | null> {
    if (!this.rdbStore) return null;

    const result = await this.rdbStore.querySql('SELECT * FROM addresses WHERE is_default = 1 LIMIT 1');
    if (result.rowCount === 0) return null;

    result.goToFirstRow();
    return new Address(
      result.getString(1),
      result.getString(2),
      result.getString(3),
      true
    );
  }

  /**
   * 关闭数据库连接
   */
  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }
}