open Base

let%test_unit "Hello World" = [%test_eq: string] (Templated.greeting ()) "Hello world!"
