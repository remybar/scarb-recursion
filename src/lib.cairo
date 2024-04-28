use starknet::ContractAddress;

#[starknet::interface]
trait IMyContract<TContractState> {
    fn spawn(self: @TContractState);
}

#[derive(Copy, Drop, Serde)]
struct FieldLayout {
    selector: felt252,
    layout: Layout
}

#[derive(Copy, Drop, Serde)]
enum Layout {
    Fixed: Span<u8>,
    Struct: Span<FieldLayout>,
    Tuple: Span<Layout>,
    Array: Span<Layout>,
}

#[starknet::contract]
mod MyContract {
    use super::{Layout, FieldLayout};

    #[storage]
    struct Storage {
    }

    #[abi(embed_v0)]
    impl MyContractImpl of super::IMyContract<ContractState> {
        fn spawn(self: @ContractState) {
            let data = array![1, 2, 3, 4, 5];
            let mut layout = array![];

            let mut i = 0;
            loop {
                if i >= data.len() { break; }

                layout.append(Layout::Array(
                    array![
                        Layout::Tuple(
                            array![
                                Layout::Fixed(array![8, 16, 32].span()),
                                Layout::Struct(
                                    array![
                                        FieldLayout {
                                            selector: 1,
                                            layout: Layout::Fixed(array![8, 16].span())
                                        }
                                    ].span()
                                )
                            ].span()
                        )   
                    ].span()
                ));

                i += 1;
            };
        }
    }
}