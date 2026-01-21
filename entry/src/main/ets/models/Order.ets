/**
 * 订单数据模型
 */
export class Order {
  orderId: string;           // 订单号
  items: Map<number, number>; // 订单菜品 {item_id: 数量}
  total: number;             // 订单总价
  address: string;           // 配送地址
  createTime: string;        // 下单时间
  status: string;            // 订单状态

  constructor(orderId: string, items: Map<number, number>, total: number, address: string, createTime: string, status: string = '待处理') {
    this.orderId = orderId;
    this.items = items;
    this.total = total;
    this.address = address;
    this.createTime = createTime;
    this.status = status;
  }

  // 将items转换为JSON字符串用于数据库存储
  getItemsJson(): string {
    const itemsObj: Record<string, number> = {};
    this.items.forEach((quantity, itemId) => {
      itemsObj[itemId.toString()] = quantity;
    });
    return JSON.stringify(itemsObj);
  }

  // 从JSON字符串解析items
  static parseItemsFromJson(jsonStr: string): Map<number, number> {
    try {
      const itemsObj: Record<string, number> = JSON.parse(jsonStr);
      const items = new Map<number, number>();
      const keys = Object.keys(itemsObj);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        items.set(parseInt(key), itemsObj[key]);
      }
      return items;
    } catch (error) {
      console.error('Failed to parse order items JSON:', error);
      return new Map<number, number>();
    }
  }
}

/**
 * 地址数据模型
 */
export class Address {
  name: string;       // 收货人姓名
  phone: string;      // 联系电话
  address: string;    // 详细地址
  isDefault: boolean; // 是否为默认地址

  constructor(name: string, phone: string, address: string, isDefault: boolean = false) {
    this.name = name;
    this.phone = phone;
    this.address = address;
    this.isDefault = isDefault;
  }

  // 获取完整地址信息
  getFullAddress(): string {
    return `${this.name} ${this.phone} ${this.address}`;
  }
}