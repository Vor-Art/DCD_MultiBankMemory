`ifndef DIRECT_TEST_SV
`define DIRECT_TEST_SV


task test_seq0();
  begin
    read_data( 1, 16'h0010, 2 );
    read_data( 1, 16'h0011, 2 );
    read_data( 1, 16'h0012, 2 );


    sync( 1, 1, 'h90 );
    write_data( 1, 16'h0219, 16'hA019, 1 );

    sync( 1, 1, 'hC0 );
    write_data( 1, 16'h0220, 16'hA020, 1 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 0 );
    read_data( 1, 16'h0220, 1 );

    sync( 1, 1, 'h100 );
    write_data( 1, 16'h0400, 16'hB010, 1 );
    sync( 1, 1, 'h104 );
    read_data( 1, 16'h0400, 0 );
    read_data( 1, 16'h0400, 0 );
    read_data( 1, 16'h0400, 1 );

    q_end(3'b001, 3'b001 );

  end endtask; // test_seq0

task test_seq1();
  begin
    read_data( 2, 16'h4110, 2 );
    read_data( 2, 16'h0111, 2 );
    read_data( 2, 16'h0112, 2 );
    read_data( 2, 16'h0113, 2 );
    read_data( 2, 16'h0114, 2 );

    sync( 4, 0, 'h40 );
    read_data( 2, 16'h0115, 0 );
    read_data( 2, 16'h0116, 0 );
    read_data( 2, 16'h0117, 1 );

    sync( 2, 2, 'hC0 );      
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 0 );
    read_data( 2, 16'h0220, 1 );


    sync( 0, 2, 'hE0 );      
    write_data( 2, 16'h0120, 16'hA120, 0 );
    write_data( 2, 16'h0121, 16'hA121, 0 );
    write_data( 2, 16'h0122, 16'hA122, 0 );
    write_data( 2, 16'h0123, 16'hA123, 0 );
    write_data( 2, 16'h0124, 16'hA124, 0 );
    write_data( 2, 16'h0125, 16'hA125, 0 );
    write_data( 2, 16'h0126, 16'hA126, 0 );
    write_data( 2, 16'h0127, 16'hA127, 0 );
    write_data( 2, 16'h0128, 16'hA128, 0 );
    write_data( 2, 16'h0129, 16'hA129, 0 );

    write_data( 2, 16'h012A, 16'hA12A, 1 );

//     sync( 2, 0, 'hE4 );      
//     read_data( 2, 16'h0120, 0 );
//     read_data( 2, 16'h0121, 0 );
//     read_data( 2, 16'h0122, 0 );
//     read_data( 2, 16'h0123, 0 );
//     read_data( 2, 16'h0124, 0 );
//     read_data( 2, 16'h0125, 0 );
//     read_data( 2, 16'h0126, 0 );
//     read_data( 2, 16'h0127, 0 );
//     read_data( 2, 16'h0128, 0 );
//     read_data( 2, 16'h0129, 0 );
//     read_data( 2, 16'h0120, 0 );
//     read_data( 2, 16'h0121, 0 );
//     read_data( 2, 16'h0122, 0 );
//     read_data( 2, 16'h0123, 0 );
//     read_data( 2, 16'h0124, 0 );
    read_data( 2, 16'h0125, 0 );
    read_data( 2, 16'h0126, 0 );
    read_data( 2, 16'h0127, 0 );
    read_data( 2, 16'h0128, 0 );
    read_data( 2, 16'h0129, 0 );
    read_data( 2, 16'h012A, 1 );

    sync( 2, 2, 'h100 );
    write_data( 1, 16'h0400, 16'hC020, 1 );
    sync( 2, 2, 'h105 );
    read_data( 2, 16'h0400, 0 );
    read_data( 2, 16'h0400, 0 );
    read_data( 2, 16'h0400, 1 );

    sync( 0, 2, 'h120 );
    write_data( 2, 16'h0400, 16'hC0E0, 1 );
    write_data( 2, 16'h0400, 16'hC0E1, 1 );
    sync( 2, 0, 'h128 );
    read_data( 2, 16'h0400, 0 );
    read_data( 2, 16'h0400, 0 );
    read_data( 2, 16'h0400, 1 );


    q_end(3'b010, 3'b010 );

  end 
endtask; // test_seq1

task test_seq2();
  begin
    read_data( 4, 16'h8210, 2 );
    read_data( 4, 16'h0211, 2 );
    read_data( 4, 16'h0212, 0 );
    read_data( 4, 16'h0213, 0 );
    read_data( 4, 16'h0214, 0 );
    read_data( 4, 16'h0215, 0 );
    read_data( 4, 16'h0216, 0 );
    read_data( 4, 16'h0217, 0 );
    read_data( 4, 16'h0218, 1 );

    sync( 4, 0, 'h80 );      
    read_data( 4, 16'h0219, 4 );

    sync( 4, 0, 'hA0 );      
    read_data( 4, 16'h0219, 4 );

    sync( 4, 4, 'hC0 );      
    write_data( 4, 16'h0220, 16'hA220, 1 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 0 );
    read_data( 4, 16'h0220, 1 );

    sync( 0, 4, 'h11F );
    write_data( 4, 16'h0400, 16'hD0E0, 1 );
    write_data( 4, 16'h0400, 16'hD0E1, 1 );
    sync( 4, 0, 'h126 );
    read_data( 4, 16'h0400, 0 );
    read_data( 4, 16'h0400, 0 );
    read_data( 4, 16'h0400, 1 );


    q_end( 3'b100, 3'b100 );

  end endtask; // test_seq2


task direct_test();
  begin
//     fork
//       begin
//         test_seq0();
//       end
//       begin
//         fork
//           test_seq1();
//           test_seq2();
//         join
//       end
//     join
    fork
      test_seq0();
      test_seq1();
      test_seq2();
    join
  end 
endtask; // direct_test


`endif // DIRECT_TEST_SV
