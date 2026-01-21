import { router } from '@kit.ArkUI';
import { Address } from '../models/Order';
import { DatabaseManager } from '../database/DatabaseManager';
import { AppStateManager } from '../managers/AppStateManager';

/**
 * 地址填写页面
 */
@Entry
@Component
export struct AddressPage {
  @State name: string = '';
  @State phone: string = '';
  @State address: string = '';
  @State savedAddresses: Address[] = [];
  @State selectedAddressIndex: number = -1;
  @State isFormValid: boolean = false;

  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private appState: AppStateManager = AppStateManager.getInstance();

  aboutToAppear(): void {
    this.loadSavedAddresses();
  }

  /**
   * 加载保存的地址
   */
  private async loadSavedAddresses(): Promise<void> {
    try {
      this.savedAddresses = await this.dbManager.getAllAddresses();
    } catch (error) {
      console.error('Failed to load saved addresses:', error);
    }
  }

  /**
   * 选择已保存的地址
   */
  private selectAddress(index: number): void {
    if (index >= 0 && index < this.savedAddresses.length) {
      const selectedAddress = this.savedAddresses[index];
      this.name = selectedAddress.name;
      this.phone = selectedAddress.phone;
      this.address = selectedAddress.address;
      this.selectedAddressIndex = index;
      this.validateForm();
    }
  }

  /**
   * 表单验证
   */
  private validateForm(): void {
    const nameValid = this.name.trim().length > 0;
    const phoneValid = /^1[3-9]\d{9}$/.test(this.phone.trim());
    const addressValid = this.address.trim().length > 10; // 地址至少10个字符

    this.isFormValid = nameValid && phoneValid && addressValid;
  }

  /**
   * 保存地址
   */
  private async saveAddress(): Promise<void> {
    if (!this.isFormValid) return;

    const newAddress = new Address(
      this.name.trim(),
      this.phone.trim(),
      this.address.trim(),
      false // 默认不是默认地址
    );

    try {
      await this.dbManager.saveAddress(newAddress);
      this.appState.setSelectedAddress(newAddress);

      // 显示保存成功提示
      try {
        AlertDialog.show({
          title: '保存成功',
          message: '地址已保存，是否继续下单？',
          primaryButton: {
            value: '继续下单',
            action: () => {
              try {
                router.pushUrl({
                  url: 'pages/OrderConfirmPage'
                });
              } catch (navError) {
                console.error('Failed to navigate to order page:', navError);
              }
            }
          },
          secondaryButton: {
            value: '留在当前页',
            action: () => {
              this.loadSavedAddresses(); // 重新加载地址列表
            }
          }
        });
      } catch (dialogError) {
        console.error('Failed to show save success dialog:', dialogError);
      }
    } catch (error) {
      console.error('Failed to save address:', error);
      try {
        AlertDialog.show({
          title: '保存失败',
          message: '地址保存失败，请重试',
          primaryButton: {
            value: '确定',
            action: () => {}
          }
        });
      } catch (dialogError) {
        console.error('Failed to show save error dialog:', dialogError);
      }
    }
  }

  /**
   * 直接下单（不保存地址）
   */
  private proceedWithoutSaving(): void {
    if (!this.isFormValid) {
      try {
        AlertDialog.show({
          title: '信息不完整',
          message: '请填写完整的收货信息',
          primaryButton: {
            value: '确定',
            action: () => {}
          }
        });
      } catch (error) {
        console.error('Failed to show validation dialog:', error);
      }
      return;
    }

    const tempAddress = new Address(
      this.name.trim(),
      this.phone.trim(),
      this.address.trim(),
      false
    );

    this.appState.setSelectedAddress(tempAddress);
    try {
      router.pushUrl({
        url: 'pages/OrderConfirmPage'
      });
    } catch (error) {
      console.error('Failed to navigate to order page:', error);
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          // 标题
          Text('填写收货地址')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 16, left: 16, right: 16 })

          // 已保存地址选择
          if (this.savedAddresses.length > 0) {
            Column() {
              Text('选择已保存地址')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12, left: 16, right: 16 })

              List({ space: 8 }) {
                ForEach(this.savedAddresses, (savedAddress: Address, index: number) => {
                  ListItem() {
                    this.SavedAddressCard(savedAddress, index)
                  }
                })
              }
              .width('100%')
              .height(200)
              .padding({ left: 16, right: 16 })

              Divider()
                .width('100%')
                .height(1)
                .color(Color.Gray)
                .margin({ top: 16, bottom: 16 })
            }
          }

          // 新地址填写表单
          Column() {
            Text('新增收货地址')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16, left: 16, right: 16 })

            // 收货人姓名
            Column() {
              Text('收货人姓名')
                .fontSize(14)
                .fontColor(Color.Gray)
                .margin({ bottom: 8, left: 16, right: 16 })

              TextInput({
                placeholder: '请输入收货人姓名',
                text: this.name
              })
              .width('100%')
              .height(40)
              .padding({ left: 12, right: 12 })
              .backgroundColor(Color.White)
              .border({
                width: 1,
                color: Color.Gray,
                radius: 4
              })
              .margin({ left: 16, right: 16, bottom: 16 })
              .onChange((value: string) => {
                this.name = value;
                this.validateForm();
              })
            }

            // 联系电话
            Column() {
              Text('联系电话')
                .fontSize(14)
                .fontColor(Color.Gray)
                .margin({ bottom: 8, left: 16, right: 16 })

              TextInput({
                placeholder: '请输入11位手机号码',
                text: this.phone
              })
              .width('100%')
              .height(40)
              .padding({ left: 12, right: 12 })
              .backgroundColor(Color.White)
              .border({
                width: 1,
                color: Color.Gray,
                radius: 4
              })
              .margin({ left: 16, right: 16, bottom: 16 })
              .maxLength(11)
              .onChange((value: string) => {
                this.phone = value;
                this.validateForm();
              })
            }

            // 详细地址
            Column() {
              Text('详细地址')
                .fontSize(14)
                .fontColor(Color.Gray)
                .margin({ bottom: 8, left: 16, right: 16 })

              TextArea({
                placeholder: '请输入详细收货地址',
                text: this.address
              })
              .width('100%')
              .height(80)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Color.White)
              .border({
                width: 1,
                color: Color.Gray,
                radius: 4
              })
              .margin({ left: 16, right: 16, bottom: 24 })
              .onChange((value: string) => {
                this.address = value;
                this.validateForm();
              })
            }

            // 操作按钮
            Row() {
              Button('保存并下单')
                .fontSize(16)
                .backgroundColor(this.isFormValid ? Color.Blue : Color.Gray)
                .fontColor(Color.White)
                .layoutWeight(1)
                .height(44)
                .margin({ right: 8 })
                .enabled(this.isFormValid)
                .onClick(() => {
                  this.saveAddress();
                })

              Button('直接下单')
                .fontSize(16)
                .backgroundColor(this.isFormValid ? Color.Green : Color.Gray)
                .fontColor(Color.White)
                .layoutWeight(1)
                .height(44)
                .margin({ left: 8 })
                .enabled(this.isFormValid)
                .onClick(() => {
                  this.proceedWithoutSaving();
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 32 })
          }
        }
      }
    }
    .title('收货地址')
  }

  /**
   * 已保存地址卡片
   */
  @Builder
  SavedAddressCard(savedAddress: Address, index: number) {
    Row() {
      Column() {
        Row() {
          Text(savedAddress.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ right: 8 })

          if (savedAddress.isDefault) {
            Text('默认')
              .fontSize(12)
              .fontColor(Color.Red)
              .backgroundColor('#FFF0F0')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }
        }
        .margin({ bottom: 4 })

        Text(savedAddress.phone)
          .fontSize(14)
          .fontColor(Color.Gray)
          .margin({ bottom: 4 })

        Text(savedAddress.address)
          .fontSize(14)
          .fontColor(Color.Black)
      }
      .layoutWeight(1)

      Radio({
        value: index.toString(),
        group: 'address'
      })
      .checked(this.selectedAddressIndex === index)
      .onChange((isChecked: boolean) => {
        if (isChecked) {
          this.selectAddress(index);
        }
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.selectedAddressIndex === index ? '#E6F3FF' : Color.White)
    .borderRadius(8)
    .border({
      width: this.selectedAddressIndex === index ? 2 : 1,
      color: this.selectedAddressIndex === index ? Color.Blue : Color.Gray,
      radius: 8
    })
    .onClick(() => {
      this.selectAddress(index);
    })
  }
}