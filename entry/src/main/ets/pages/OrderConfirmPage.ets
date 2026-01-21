import { router } from '@kit.ArkUI';
import { CartItem } from '../models/MenuItem';
import { Order } from '../models/Order';
import { DatabaseManager } from '../database/DatabaseManager';
import { AppStateManager } from '../managers/AppStateManager';

/**
 * 订单确认页面
 */
@Entry
@Component
export struct OrderConfirmPage {
  @State cartItems: CartItem[] = [];
  @State totalPrice: number = 0;
  @State selectedAddress: string = '';

  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private appState: AppStateManager = AppStateManager.getInstance();

  aboutToAppear(): void {
    this.loadOrderData();
  }

  /**
   * 加载订单数据
   */
  private loadOrderData(): void {
    this.cartItems = [...this.appState.cartItems];
    this.totalPrice = this.appState.totalPrice;

    if (this.appState.selectedAddress) {
      this.selectedAddress = this.appState.selectedAddress.getFullAddress();
    } else {
      // 如果没有选择地址，返回地址页面
      try {
        router.replaceUrl({
          url: 'pages/AddressPage'
        });
      } catch (error) {
        console.error('Failed to navigate to address page:', error);
      }
    }
  }

  /**
   * 提交订单
   */
  private async submitOrder(): Promise<void> {
    try {
      // 创建订单对象
      const orderId = this.appState.generateOrderId();
      const items = this.appState.getCartItemsMap();
      const order = new Order(
        orderId,
        items,
        this.totalPrice,
        this.selectedAddress,
        this.appState.getCurrentTimeString()
      );

      // 处理订单提交
      // 先扣减库存
      await this.dbManager.updateStocks(items);
      // 再创建订单
      await this.dbManager.createOrder(order);

      // 提交成功，清空购物车
      this.appState.clearCart();

      // 显示成功提示
      try {
        AlertDialog.show({
          title: '下单成功',
          message: `您的订单号是：${orderId}\n请耐心等待配送`,
          primaryButton: {
            value: '返回首页',
            action: () => {
              try {
                router.replaceUrl({
                  url: 'pages/Index'
                });
              } catch (navError) {
                console.error('Failed to navigate to home page:', navError);
              }
            }
          },
          secondaryButton: {
            value: '确定',
            action: () => {}
          }
        });
      } catch (dialogError) {
        console.error('Failed to show order success dialog:', dialogError);
      }

    } catch (error) {
      console.error('Order submission error:', error);
      // 提交失败
      try {
        AlertDialog.show({
          title: '下单失败',
          message: '订单提交失败，请检查库存或稍后重试',
          primaryButton: {
            value: '确定',
            action: () => {}
          }
        });
      } catch (dialogError) {
        console.error('Failed to show order error dialog:', dialogError);
      }
    }
  }

  /**
   * 返回修改地址
   */
  private goBackToAddress(): void {
    try {
      router.replaceUrl({
        url: 'pages/AddressPage'
      });
    } catch (error) {
      console.error('Failed to navigate to address page:', error);
    }
  }

  /**
   * 返回购物车
   */
  private goBackToCart(): void {
    try {
      router.replaceUrl({
        url: 'pages/CartPage'
      });
    } catch (error) {
      console.error('Failed to navigate to cart page:', error);
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          // 标题
          Text('确认订单')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 16, left: 16, right: 16 })

          // 收货地址
          Column() {
            Row() {
              Text('收货地址')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ right: 8 })

              Text('(点击修改)')
                .fontSize(12)
                .fontColor(Color.Blue)
            }
            .margin({ bottom: 8, left: 16, right: 16 })

            Text(this.selectedAddress)
              .fontSize(14)
              .fontColor(Color.Black)
              .lineHeight(20)
              .margin({ left: 16, right: 16, bottom: 16 })
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 16 })
          .onClick(() => {
            this.goBackToAddress();
          })

          // 订单商品
          Column() {
            Text('商品清单')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12, left: 16, right: 16 })

            List({ space: 8 }) {
              ForEach(this.cartItems, (cartItem: CartItem) => {
                ListItem() {
                  this.OrderItemCard(cartItem)
                }
              })
            }
            .width('100%')
            .height(200)
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 16 })

          // 订单信息
          Column() {
            Row() {
              Text('商品数量')
                .fontSize(14)
                .fontColor(Color.Gray)
              Text(`${this.cartItems.reduce((sum, item) => sum + item.quantity, 0)} 件`)
                .fontSize(14)
                .fontColor(Color.Black)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8, left: 16, right: 16 })

            Row() {
              Text('配送费')
                .fontSize(14)
                .fontColor(Color.Gray)
              Text('¥0.00')
                .fontSize(14)
                .fontColor(Color.Black)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12, left: 16, right: 16 })

            Divider()
              .width('100%')
              .height(1)
              .color(Color.Gray)
              .margin({ left: 16, right: 16, bottom: 12 })

            Row() {
              Text('订单总价')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Red)
              Text(`¥${this.totalPrice.toFixed(2)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Red)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ left: 16, right: 16, bottom: 16 })
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 32 })

          // 操作按钮
          Row() {
            Button('返回修改')
              .fontSize(16)
              .backgroundColor(Color.Gray)
              .fontColor(Color.White)
              .layoutWeight(1)
              .height(44)
              .margin({ right: 8 })
              .onClick(() => {
                this.goBackToCart();
              })

            Button('提交订单')
              .fontSize(16)
              .backgroundColor(Color.Red)
              .fontColor(Color.White)
              .layoutWeight(2)
              .height(44)
              .margin({ left: 8 })
              .onClick(() => {
                this.submitOrder();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 32 })
        }
      }
    }
    .title('订单确认')
  }

  /**
   * 订单商品卡片
   */
  @Builder
  OrderItemCard(cartItem: CartItem) {
    Row() {
      // 商品信息
      Column() {
        Text(cartItem.menuItem.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })

        Text(`¥${cartItem.menuItem.price.toFixed(2)}`)
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)

      // 数量和小计
      Column() {
        Text(`x${cartItem.quantity}`)
          .fontSize(14)
          .fontColor(Color.Gray)
          .margin({ bottom: 4 })

        Text(`¥${cartItem.getSubtotal().toFixed(2)}`)
          .fontSize(14)
          .fontColor(Color.Red)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
  }
}