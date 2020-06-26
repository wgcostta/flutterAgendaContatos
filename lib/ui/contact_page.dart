import 'dart:io';

import 'package:agendacontatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact}); // parametro opcional

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _nameFocus = FocusNode();
  bool _bUserEdit = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _phoneController.text = _editedContact.telefone;
      _emailController.text = _editedContact.email;
      _nameController.text = _editedContact.nome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.nome ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editedContact.nome != null &&
                  _editedContact.nome.isNotEmpty) {
                Navigator.pop(context, _editedContact);
                //remove a tela e volta para a tela anterior. (PILHA)
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.imagem != null
                              ? FileImage(File(_editedContact.imagem))
                              : AssetImage("images/person.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(
                            source: ImageSource
                                .gallery) //pode ser chamado a Camera tb
                        .then((file) {
                      setState(() {
                        if (file == null) {
                          return;
                        } else {
                          _editedContact.imagem = file.path;
                        }
                      });
                    });
                  },
                ),
                new TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _bUserEdit = true;
                    setState(() {
                      _editedContact.nome = text;
                    });
                  },
                ),
                new TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "e-mail"),
                  onChanged: (text) {
                    _bUserEdit = true;

                    _editedContact.nome = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                new TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "telefone"),
                  onChanged: (text) {
                    _bUserEdit = true;

                    _editedContact.nome = text;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }

  Future<bool> _requestPop() {
    if (_bUserEdit) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações ?"),
              content: Text("Se sair, vai perder as informações"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Permanecer"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Descartar"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
