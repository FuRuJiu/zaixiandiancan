/**
 * 菜品数据模型
 */
export class MenuItem {
  itemId: number;      // 菜品ID
  name: string;        // 菜品名称
  price: number;       // 菜品价格
  category: string;    // 菜品分类
  stock: number;       // 菜品库存
  image?: string;      // 菜品图片（可选）

  constructor(itemId: number, name: string, price: number, category: string, stock: number, image?: string) {
    this.itemId = itemId;
    this.name = name;
    this.price = price;
    this.category = category;
    this.stock = stock;
    this.image = image;
  }
}

/**
 * 购物车项数据模型
 */
export class CartItem {
  menuItem: MenuItem;  // 菜品信息
  quantity: number;    // 数量

  constructor(menuItem: MenuItem, quantity: number = 1) {
    this.menuItem = menuItem;
    this.quantity = quantity;
  }

  // 计算小计
  getSubtotal(): number {
    return this.menuItem.price * this.quantity;
  }
}