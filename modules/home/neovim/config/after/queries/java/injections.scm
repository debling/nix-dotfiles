; extends


(annotation
  name: (identifier) @name (#eq? @name "Query")
  arguments: (annotation_argument_list (string_literal (string_fragment) @injection.content))
  (#set! injection.language "sql"))


(annotation
  name: (identifier) @name (#eq? @name "Query")
  arguments: (annotation_argument_list (string_literal (multiline_string_fragment) @injection.content))
  (#set! injection.language "sql")
  )


(annotation
  name: (identifier) @name (#eq? @name "Query")
  arguments: (annotation_argument_list (element_value_pair
                                         value: (string_literal (multiline_string_fragment) @injection.content)))
  (#set! injection.language "sql"))



(annotation
  name: (identifier) @name (#eq? @name "Query")
  arguments: (annotation_argument_list (element_value_pair
                                         value: (string_literal (string_fragment) @injection.content)))
  (#set! injection.language "sql"))
