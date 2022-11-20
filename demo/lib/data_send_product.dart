class SendProductData {
  const SendProductData({
    this.formNumber = '',
    this.formDate = '',
    this.formReceiver = '',
    this.products = const <Product>[],
    this.sum = 0,
  });

  final String formNumber;
  final String formDate;
  final String formReceiver;
  final List<Product> products;
  final int sum;
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
