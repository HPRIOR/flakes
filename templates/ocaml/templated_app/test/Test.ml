open Base
open Templated_app

let%test_unit "Hello World" = [%test_eq: string] (TemplatedApp.greeting ()) "Hello world!"
