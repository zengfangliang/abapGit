CLASS ltcl_pack DEFINITION DEFERRED.
CLASS zcl_abapgit_git_pack DEFINITION LOCAL FRIENDS ltcl_pack.

CLASS ltcl_pack DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS: c_sha TYPE zif_abapgit_definitions=>ty_sha1 VALUE '5f46cb3c4b7f0b3600b64f744cde614a283a88dc'.

    METHODS:
      tree FOR TESTING
        RAISING zcx_abapgit_exception,
      commit FOR TESTING
        RAISING zcx_abapgit_exception,
      commit_newline FOR TESTING
        RAISING zcx_abapgit_exception,
      pack_short FOR TESTING
        RAISING zcx_abapgit_exception,
      pack_long FOR TESTING
        RAISING zcx_abapgit_exception,
      pack_multiple FOR TESTING
        RAISING zcx_abapgit_exception,
      sort_tree1 FOR TESTING,
      sort_tree2 FOR TESTING,
      type_and_length01 FOR TESTING
        RAISING zcx_abapgit_exception,
      type_and_length02 FOR TESTING
        RAISING zcx_abapgit_exception.

    METHODS:
      object_blob
        IMPORTING iv_data          TYPE xstring
        RETURNING VALUE(rs_object) TYPE zif_abapgit_definitions=>ty_object
        RAISING   zcx_abapgit_exception.

ENDCLASS.       "ltcl_Pack


CLASS ltcl_pack IMPLEMENTATION.

  METHOD type_and_length01.

    DATA: lv_result TYPE xstring.

    lv_result = zcl_abapgit_git_pack=>type_and_length(
      iv_type   = zif_abapgit_definitions=>gc_type-commit
      iv_length = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '9406' ).

  ENDMETHOD.

  METHOD type_and_length02.

    DATA: lv_result TYPE xstring.

    lv_result = zcl_abapgit_git_pack=>type_and_length(
      iv_type   = zif_abapgit_definitions=>gc_type-blob
      iv_length = 90000 ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'B0F92B' ).

  ENDMETHOD.

  METHOD sort_tree1.

    DATA: lt_tree TYPE zcl_abapgit_git_pack=>ty_nodes_tt.

    FIELD-SYMBOLS: <ls_tree> LIKE LINE OF lt_tree.


    APPEND INITIAL LINE TO lt_tree ASSIGNING <ls_tree>.
    <ls_tree>-chmod = zif_abapgit_definitions=>gc_chmod-file.
    <ls_tree>-name  = 'b.txt'.
    <ls_tree>-sha1  = '0123'.

    APPEND INITIAL LINE TO lt_tree ASSIGNING <ls_tree>.
    <ls_tree>-chmod = zif_abapgit_definitions=>gc_chmod-file.
    <ls_tree>-name  = 'a.txt'.
    <ls_tree>-sha1  = '0123'.

    lt_tree = zcl_abapgit_git_pack=>sort_tree( lt_tree ).

    READ TABLE lt_tree INDEX 1 ASSIGNING <ls_tree>.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = <ls_tree>-name
      exp = 'a.txt' ).

  ENDMETHOD.

  METHOD sort_tree2.

    DATA: lt_tree TYPE zcl_abapgit_git_pack=>ty_nodes_tt.

    FIELD-SYMBOLS: <ls_tree> LIKE LINE OF lt_tree.


    APPEND INITIAL LINE TO lt_tree ASSIGNING <ls_tree>.
    <ls_tree>-chmod = zif_abapgit_definitions=>gc_chmod-file.
    <ls_tree>-name  = 'foo.txt'.
    <ls_tree>-sha1  = '0123'.

    APPEND INITIAL LINE TO lt_tree ASSIGNING <ls_tree>.
    <ls_tree>-chmod = zif_abapgit_definitions=>gc_chmod-dir.
    <ls_tree>-name  = 'foo'.
    <ls_tree>-sha1  = '0123'.

    lt_tree = zcl_abapgit_git_pack=>sort_tree( lt_tree ).

    READ TABLE lt_tree INDEX 1 ASSIGNING <ls_tree>.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = <ls_tree>-name
      exp = 'foo.txt' ).

  ENDMETHOD.

  METHOD pack_multiple.

    CONSTANTS: lc_data TYPE x LENGTH 15 VALUE '123456789ABCDEF545794254754554',
               lc_sha  TYPE zif_abapgit_definitions=>ty_sha1 VALUE '5f46cb3c4b7f0b3600b64f744cde614a283a88dc'.

    DATA: lt_objects TYPE zif_abapgit_definitions=>ty_objects_tt,
          ls_object  LIKE LINE OF lt_objects,
          lt_nodes   TYPE zcl_abapgit_git_pack=>ty_nodes_tt,
          ls_node    LIKE LINE OF lt_nodes,
          ls_commit  TYPE zcl_abapgit_git_pack=>ty_commit,
          lt_result  TYPE zif_abapgit_definitions=>ty_objects_tt,
          lv_data    TYPE xstring.


* blob
    lv_data = lc_data.
    CLEAR ls_object.
    ls_object-sha1 = zcl_abapgit_hash=>sha1( iv_type = zif_abapgit_definitions=>gc_type-blob iv_data = lv_data ).
    ls_object-type = zif_abapgit_definitions=>gc_type-blob.
    ls_object-data = lv_data.
    ls_object-adler32 = zcl_abapgit_hash=>adler32( lv_data ).
    APPEND ls_object TO lt_objects.

* commit
    CLEAR ls_commit.
    ls_commit-tree      = lc_sha.
    ls_commit-parent    = lc_sha.
    ls_commit-author    = 'John Foobar'.
    ls_commit-committer = 'John Foobar'.
    ls_commit-body      = 'body'.
    lv_data = zcl_abapgit_git_pack=>encode_commit( ls_commit ).
    CLEAR ls_object.
    ls_object-sha1 = zcl_abapgit_hash=>sha1( iv_type = zif_abapgit_definitions=>gc_type-commit iv_data = lv_data ).
    ls_object-type = zif_abapgit_definitions=>gc_type-commit.
    ls_object-data = lv_data.
    ls_object-adler32 = zcl_abapgit_hash=>adler32( lv_data ).
    APPEND ls_object TO lt_objects.

* tree
    CLEAR ls_node.
    ls_node-chmod     = '12456'.
    ls_node-name      = 'foobar.abap'.
    ls_node-sha1      = lc_sha.
    APPEND ls_node TO lt_nodes.
    lv_data = zcl_abapgit_git_pack=>encode_tree( lt_nodes ).
    CLEAR ls_object.
    ls_object-sha1 = zcl_abapgit_hash=>sha1( iv_type = zif_abapgit_definitions=>gc_type-tree iv_data = lv_data ).
    ls_object-type = zif_abapgit_definitions=>gc_type-tree.
    ls_object-data = lv_data.
    ls_object-adler32 = zcl_abapgit_hash=>adler32( lv_data ).
    APPEND ls_object TO lt_objects.


    CLEAR lv_data.
    lv_data = zcl_abapgit_git_pack=>encode( lt_objects ).
    lt_result = zcl_abapgit_git_pack=>decode( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = lt_objects
        act = lt_result ).

  ENDMETHOD.                    "encode_decode_pack_multiple

  METHOD object_blob.

    rs_object-sha1 = zcl_abapgit_hash=>sha1( iv_type = zif_abapgit_definitions=>gc_type-blob
                                             iv_data = iv_data ).
    rs_object-type = zif_abapgit_definitions=>gc_type-blob.
    rs_object-data = iv_data.
    rs_object-adler32 = zcl_abapgit_hash=>adler32( iv_data ).

  ENDMETHOD.                    "object_blob

  METHOD pack_short.

    CONSTANTS: lc_data TYPE x LENGTH 8 VALUE '0123456789ABCDEF'.

    DATA: lt_objects TYPE zif_abapgit_definitions=>ty_objects_tt,
          ls_object  LIKE LINE OF lt_objects,
          lt_result  TYPE zif_abapgit_definitions=>ty_objects_tt,
          lv_data    TYPE xstring.


    lv_data = lc_data.

    ls_object = object_blob( lv_data ).
    APPEND ls_object TO lt_objects.

    CLEAR lv_data.
    lv_data = zcl_abapgit_git_pack=>encode( lt_objects ).
    lt_result = zcl_abapgit_git_pack=>decode( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = lt_objects
        act = lt_result ).

  ENDMETHOD.                    "encode_decode_pack

  METHOD pack_long.

    CONSTANTS: lc_data TYPE x LENGTH 8 VALUE '0123456789ABCDEF'.

    DATA: lt_objects TYPE zif_abapgit_definitions=>ty_objects_tt,
          ls_object  LIKE LINE OF lt_objects,
          lv_xstring TYPE xstring,
          lt_result  TYPE zif_abapgit_definitions=>ty_objects_tt,
          lv_data    TYPE xstring.


    lv_xstring = lc_data.
    DO 20 TIMES.
      CONCATENATE lv_xstring lv_data INTO lv_data IN BYTE MODE.
    ENDDO.

    ls_object = object_blob( lv_data ).
    APPEND ls_object TO lt_objects.

    CLEAR lv_data.
    lv_data = zcl_abapgit_git_pack=>encode( lt_objects ).
    lt_result = zcl_abapgit_git_pack=>decode( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = lt_objects
        act = lt_result ).

  ENDMETHOD.                    "encode_decode_pack_long

  METHOD tree.

    DATA: lt_nodes  TYPE zcl_abapgit_git_pack=>ty_nodes_tt,
          ls_node   LIKE LINE OF lt_nodes,
          lv_data   TYPE xstring,
          lt_result TYPE zcl_abapgit_git_pack=>ty_nodes_tt.

    CLEAR ls_node.
    ls_node-chmod = zif_abapgit_definitions=>gc_chmod-file.
    ls_node-name = 'foobar.txt'.
    ls_node-sha1 = c_sha.
    APPEND ls_node TO lt_nodes.

    lv_data = zcl_abapgit_git_pack=>encode_tree( lt_nodes ).
    lt_result = zcl_abapgit_git_pack=>decode_tree( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = lt_nodes
        act = lt_result ).

  ENDMETHOD.                    "tree

  METHOD commit.

    DATA: ls_commit TYPE zcl_abapgit_git_pack=>ty_commit,
          ls_result TYPE zcl_abapgit_git_pack=>ty_commit,
          lv_data   TYPE xstring.


    ls_commit-tree      = c_sha.
    ls_commit-parent    = c_sha.
    ls_commit-author    = 'larshp <larshp@hotmail.com> 1387823471 +0100'.
    ls_commit-committer = 'larshp <larshp@hotmail.com> 1387823471 +0100'.
    ls_commit-body      = 'very informative'.

    lv_data = zcl_abapgit_git_pack=>encode_commit( ls_commit ).
    ls_result = zcl_abapgit_git_pack=>decode_commit( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = ls_commit
        act = ls_result ).

  ENDMETHOD.                    "commit

  METHOD commit_newline.

    DATA: ls_commit TYPE zcl_abapgit_git_pack=>ty_commit,
          ls_result TYPE zcl_abapgit_git_pack=>ty_commit,
          lv_data   TYPE xstring.


    ls_commit-tree      = c_sha.
    ls_commit-parent    = c_sha.
    ls_commit-author    = 'larshp <larshp@hotmail.com> 1387823471 +0100'.
    ls_commit-committer = 'larshp <larshp@hotmail.com> 1387823471 +0100'.
    ls_commit-body      = 'very informative'
                        && zif_abapgit_definitions=>gc_newline
                        && zif_abapgit_definitions=>gc_newline.

    lv_data = zcl_abapgit_git_pack=>encode_commit( ls_commit ).
    ls_result = zcl_abapgit_git_pack=>decode_commit( lv_data ).

    cl_abap_unit_assert=>assert_equals(
        exp = ls_commit
        act = ls_result ).

  ENDMETHOD.

ENDCLASS.
