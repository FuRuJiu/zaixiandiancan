import { router } from '@kit.ArkUI';
import { MenuItem } from '../models/MenuItem';
import { DatabaseManager } from '../database/DatabaseManager';
import { AppStateManager } from '../managers/AppStateManager';
import { getAppContext } from '../common/AppContext';

/**
 * 主页 - 菜品分类展示
 */
@Entry
@Component
struct Index {
  @State menuItems: MenuItem[] = [];
  @State selectedCategory: number = 0;
  @State filteredItems: MenuItem[] = [];

  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private appState: AppStateManager = AppStateManager.getInstance();

  aboutToAppear(): void {
    this.initData();
  }

  /**
   * 初始化数据
   */
  private async initData(): Promise<void> {
    try {
      const context = getAppContext();
      await this.appState.init(context);
      await this.dbManager.initDatabase(context);
      this.menuItems = await this.dbManager.getAllMenuItems();
      this.filterItemsByCategory(0);
    } catch (error) {
      console.error('Failed to initialize data:', error);
    }
  }

  /**
   * 根据分类筛选菜品
   */
  private filterItemsByCategory(categoryIndex: number): void {
    if (categoryIndex === 0) {
      // 全部菜品
      this.filteredItems = this.menuItems;
    } else {
      const category = this.appState.categories[categoryIndex - 1];
      this.filteredItems = this.menuItems.filter(item => item.category === category);
    }
  }

  /**
   * 添加到购物车
   */
  private addToCart(menuItem: MenuItem): void {
    this.appState.addToCart(menuItem);
  }

  /**
   * 获取购物车中菜品的数量
   */
  private getCartItemCount(itemId: number): number {
    return this.appState.getCartItemCount(itemId);
  }

  build() {
    Navigation() {
      Column() {
        // 标题栏
        Row() {
          Text('在线点餐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16, top: 12, bottom: 12 })
          Blank()
          // 购物车图标和数量
          Button({
            type: ButtonType.Circle
          }) {
            Row() {
              Image($r('app.media.startIcon'))
                .width(24)
                .height(24)
              if (this.appState.totalQuantity > 0) {
                Text(this.appState.totalQuantity.toString())
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor(Color.Red)
                  .borderRadius(10)
                  .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                  .margin({ left: -8, top: -8 })
              }
            }
          }
          .width(48)
          .height(48)
          .margin({ right: 16 })
          .backgroundColor(Color.Blue)
          .onClick(() => {
            // 跳转到购物车页面
            router.pushUrl({ url: 'pages/CartPage' })
              .catch((error: object) => {
                console.error('Failed to navigate to cart page:', error);
              });
          })
        }
        .width('100%')
        .backgroundColor(Color.White)

        // 分类标签页
        Tabs({
          barPosition: BarPosition.Start,
          index: this.selectedCategory
        }) {
          TabContent() {
            Text('全部')
              .fontSize(16)
              .fontWeight(this.selectedCategory === 0 ? FontWeight.Bold : FontWeight.Normal)
          }
          .tabBar('全部')

          ForEach(this.appState.categories, (category: string, index: number) => {
            TabContent() {
              Text(category)
                .fontSize(16)
                .fontWeight(this.selectedCategory === index + 1 ? FontWeight.Bold : FontWeight.Normal)
            }
            .tabBar(category)
          })
        }
        .width('100%')
        .height('100%')
        .onChange((index: number) => {
          this.selectedCategory = index;
          this.filterItemsByCategory(index);
        })

        // 菜品列表
        List({ space: 8 }) {
          ForEach(this.filteredItems, (item: MenuItem) => {
            ListItem() {
              this.MenuItemCard(item)
            }
          })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
    }
    .title('在线点餐')
    .menus([
      {
        value: 'cart',
        icon: $r('app.media.startIcon'),
        action: () => {
          router.pushUrl({ url: 'pages/CartPage' })
            .catch((error: object) => {
              console.error('Failed to navigate to cart page:', error);
            });
        }
      }
    ])
  }


  /**
   * 菜品卡片
   */
  @Builder
  MenuItemCard(item: MenuItem) {
    Row() {
      // 菜品信息
      Column() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })

        Text(`¥${item.price.toFixed(2)}`)
          .fontSize(14)
          .fontColor(Color.Gray)
          .margin({ bottom: 4 })

        Text(`库存: ${item.stock}`)
          .fontSize(12)
          .fontColor(item.stock > 0 ? Color.Green : Color.Red)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 添加到购物车按钮
      Button({
        type: ButtonType.Normal,
        stateEffect: true
      }) {
        Row() {
          if (this.getCartItemCount(item.itemId) > 0) {
            Text(`已添加 ${this.getCartItemCount(item.itemId)}`)
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ right: 8 })
          }
          Text(item.stock > 0 ? '添加' : '缺货')
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .width(100)
      .height(36)
      .backgroundColor(item.stock > 0 ? Color.Blue : Color.Gray)
      .enabled(item.stock > 0)
      .onClick(() => {
        this.addToCart(item);
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: Color.Gray,
      offsetX: 0,
      offsetY: 2
    })
  }
}