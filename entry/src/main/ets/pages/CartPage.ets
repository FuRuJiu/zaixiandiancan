import { router } from '@kit.ArkUI';
import { CartItem } from '../models/MenuItem';
import { AppStateManager } from '../managers/AppStateManager';

/**
 * 购物车页面
 */
@Entry
@Component
export struct CartPage {
  @State cartItems: CartItem[] = [];
  @State totalPrice: number = 0;
  @State totalQuantity: number = 0;

  private appState: AppStateManager = AppStateManager.getInstance();

  aboutToAppear(): void {
    this.updateCartData();
  }

  /**
   * 更新购物车数据
   */
  private updateCartData(): void {
    this.cartItems = this.appState.cartItems;
    this.totalPrice = this.appState.totalPrice;
    this.totalQuantity = this.appState.totalQuantity;
  }

  /**
   * 增加菜品数量
   */
  private increaseQuantity(itemId: number): void {
    const currentCount = this.appState.getCartItemCount(itemId);
    this.appState.updateCartItemQuantity(itemId, currentCount + 1);
    this.updateCartData();
  }

  /**
   * 减少菜品数量
   */
  private decreaseQuantity(itemId: number): void {
    const currentCount = this.appState.getCartItemCount(itemId);
    if (currentCount > 1) {
      this.appState.updateCartItemQuantity(itemId, currentCount - 1);
      this.updateCartData();
    }
  }

  /**
   * 删除菜品
   */
  private removeItem(itemId: number): void {
    this.appState.removeFromCart(itemId);
    this.updateCartData();
  }

  /**
   * 清空购物车
   */
  private clearCart(): void {
    try {
      AlertDialog.show({
        title: '确认清空',
        message: '确定要清空购物车吗？',
        primaryButton: {
          value: '确定',
          action: () => {
            this.appState.clearCart();
            this.updateCartData();
          }
        },
        secondaryButton: {
          value: '取消',
          action: () => {}
        }
      });
    } catch (error) {
      console.error('Failed to show clear cart dialog:', error);
    }
  }

  /**
   * 去结算
   */
  private goToCheckout(): void {
    if (this.cartItems.length === 0) {
      try {
        AlertDialog.show({
          title: '提示',
          message: '购物车为空，请先添加菜品',
          primaryButton: {
            value: '确定',
            action: () => {}
          }
        });
      } catch (error) {
        console.error('Failed to show dialog:', error);
      }
      return;
    }

    try {
      router.pushUrl({
        url: 'pages/AddressPage'
      });
    } catch (error) {
      console.error('Failed to navigate to address page:', error);
    }
  }

  build() {
    Navigation() {
      Column() {
        // 标题栏
        Row() {
          Text('购物车')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16, top: 12, bottom: 12 })
          Blank()
          if (this.cartItems.length > 0) {
            Button('清空')
              .fontSize(14)
              .fontColor(Color.Red)
              .backgroundColor(Color.Transparent)
              .margin({ right: 16 })
              .onClick(() => {
                this.clearCart();
              })
          }
        }
        .width('100%')
        .backgroundColor(Color.White)

        // 购物车为空提示
        if (this.cartItems.length === 0) {
          Column() {
            Image($r('app.media.startIcon'))
              .width(80)
              .height(80)
              .margin({ bottom: 16 })
              .opacity(0.5)

            Text('购物车为空')
              .fontSize(16)
              .fontColor(Color.Gray)
              .margin({ bottom: 8 })

            Button('去点餐')
              .fontSize(16)
              .backgroundColor(Color.Blue)
              .fontColor(Color.White)
              .padding({ left: 24, right: 24, top: 8, bottom: 8 })
              .onClick(() => {
                router.back();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 购物车列表
          List({ space: 8 }) {
            ForEach(this.cartItems, (cartItem: CartItem) => {
              ListItem() {
                this.CartItemCard(cartItem)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8 })

          // 底部结算栏
          Column() {
            Divider()
              .width('100%')
              .height(1)
              .color(Color.Gray)

            Row() {
              Column() {
                Text(`共 ${this.totalQuantity} 件商品`)
                  .fontSize(14)
                  .fontColor(Color.Gray)
                  .margin({ bottom: 4 })

                Text(`总计: ¥${this.totalPrice.toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Red)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button('去结算')
                .fontSize(16)
                .backgroundColor(Color.Red)
                .fontColor(Color.White)
                .padding({ left: 32, right: 32, top: 12, bottom: 12 })
                .borderRadius(8)
                .onClick(() => {
                  this.goToCheckout();
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
          }
        }
      }
    }
    .title('购物车')
  }

  /**
   * 购物车项卡片
   */
  @Builder
  CartItemCard(cartItem: CartItem) {
    Row() {
      // 菜品信息
      Column() {
        Text(cartItem.menuItem.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })

        Text(`¥${cartItem.menuItem.price.toFixed(2)}`)
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 数量控制
      Row() {
        Button({
          type: ButtonType.Circle
        }) {
          Text('-')
            .fontSize(18)
            .fontColor(Color.Blue)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Gray)
        .onClick(() => {
          this.decreaseQuantity(cartItem.menuItem.itemId);
        })

        Text(cartItem.quantity.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16, right: 16 })
          .width(40)
          .textAlign(TextAlign.Center)

        Button({
          type: ButtonType.Circle
        }) {
          Text('+')
            .fontSize(18)
            .fontColor(Color.Blue)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Gray)
        .onClick(() => {
          this.increaseQuantity(cartItem.menuItem.itemId);
        })
      }
      .alignItems(VerticalAlign.Center)

      // 小计和删除按钮
      Column() {
        Text(`¥${cartItem.getSubtotal().toFixed(2)}`)
          .fontSize(14)
          .fontColor(Color.Red)
          .margin({ bottom: 4 })

        Button('删除')
          .fontSize(12)
          .fontColor(Color.Red)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.removeItem(cartItem.menuItem.itemId);
          })
      }
      .alignItems(HorizontalAlign.End)
      .margin({ left: 8 })
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