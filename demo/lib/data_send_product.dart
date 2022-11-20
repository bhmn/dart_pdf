import 'dart:typed_data';

class SendProductData {
  const SendProductData({
    this.formNumber = '',
    this.formDate = '',
    this.formReceiver = '',
    this.products = const <Product>[],
    this.sum = 0,
    this.imageInUnit8ListSender,
    this.imageInUnit8ListReceiver,
  });

  final String formNumber;
  final String formDate;
  final String formReceiver;
  final List<Product> products;
  final int sum;
  final Uint8List? imageInUnit8ListSender;
  final Uint8List? imageInUnit8ListReceiver;
}

class Product {
  const Product({
    this.rowNumber = '',
    this.product = '',
    this.productNumber = 0,
    this.productDescription = '',
  });

  final String rowNumber;
  final String product;
  final int productNumber;
  final String productDescription;
  String getIndex(int index) {
    switch (index) {
      case 0:
        return productDescription;
      case 1:
        return productNumber.toString();
      case 2:
        return product;
      case 3:
        return rowNumber;
    }
    return '';
  }
}
