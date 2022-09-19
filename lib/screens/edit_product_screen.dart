import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
  };
  var _isInit = true;

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toStringAsFixed(2),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _saveForm() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    if (_editedProduct.id != '') {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(_editedProduct);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter a valid title';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) {
                    _editedProduct = Product(
                        isFavorite: _editedProduct.isFavorite,
                        id: _editedProduct.id,
                        title: val!,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: const InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val!.isEmpty || double.tryParse(val) == null) {
                      return 'Please enter a valid price';
                    }
                    if (double.parse(val) <= 0) {
                      return 'Please enter a valid price';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) {
                    _editedProduct = Product(
                        isFavorite: _editedProduct.isFavorite,
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: double.parse(val!),
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: const InputDecoration(labelText: 'Description'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 24) {
                      return 'Please enter a valid description';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) {
                    _editedProduct = Product(
                        isFavorite: _editedProduct.isFavorite,
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: val!,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                      child: !Uri.tryParse(_imageUrlController.text)!
                              .hasAbsolutePath
                          ? const Text('Enter image URL')
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.url,
                        controller: _imageUrlController,
                        onChanged: (_) {
                          if (!Uri.tryParse(_imageUrlController.text)!
                                  .hasAbsolutePath ||
                              (!_imageUrlController.text
                                      .toLowerCase()
                                      .endsWith('.png') &&
                                  !_imageUrlController.text
                                      .toLowerCase()
                                      .endsWith('.jpg') &&
                                  !_imageUrlController.text
                                      .toLowerCase()
                                      .endsWith('.jpeg'))) {
                            return;
                          } else {
                            setState(() {});
                          }
                        },
                        onFieldSubmitted: (_) => _saveForm(),
                        validator: (val) {
                          if (!Uri.tryParse(val!)!.hasAbsolutePath ||
                              (!val.toLowerCase().endsWith('.png') &&
                                  !val.toLowerCase().endsWith('.jpg') &&
                                  !val.toLowerCase().endsWith('.jpeg'))) {
                            return 'Please enter a valid image URL';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) {
                          _editedProduct = Product(
                              isFavorite: _editedProduct.isFavorite,
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: val!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
