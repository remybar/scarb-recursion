use starknet::ContractAddress;

#[starknet::interface]
trait IMyContract<TContractState> {
    fn entity(self: @TContractState, layout: Layout) -> Span<felt252>;
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
}

#[starknet::contract]
mod MyContract {
    use super::{Layout, FieldLayout};

    #[storage]
    struct Storage {
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _read_layout(ref read_data: Array<felt252>, layout: Layout) {
            match layout {
                Layout::Fixed(layout) => {
                    InternalFunctions::_read_fixed_layout(ref read_data, layout);
                },
                Layout::Struct(layout) => {
                    InternalFunctions::_read_struct_layout(ref read_data, layout);
                },
                Layout::Tuple(layout) => {
                    InternalFunctions::_read_tuple_layout(ref read_data, layout);
                }
            };
        }

        fn _read_fixed_layout(ref read_data: Array<felt252>, layout: Span<u8>) {
            read_data.append(10);
        }
        
        fn _read_struct_layout(ref read_data: Array<felt252>, layout: Span<FieldLayout>) {
            let mut i = 0;
            loop {
                if i >= layout.len() { break; }

                let field_layout = *layout.at(i);
                InternalFunctions::_read_layout(ref read_data, field_layout.layout);

                i += 1;
            }
        }

        fn _read_tuple_layout(ref read_data: Array<felt252>, layout: Span<Layout>) {
            let mut i = 0;
            loop {
                if i >= layout.len() { break; }

                let l = *layout.at(i);
                InternalFunctions::_read_layout(ref read_data, l);

                i += 1;
            }            
        }
    }

    #[abi(embed_v0)]
    impl MyContractImpl of super::IMyContract<ContractState> {
        fn entity(self: @ContractState, layout: Layout) -> Span<felt252> {
            let mut read_data = ArrayTrait::<felt252>::new();

            InternalFunctions::_read_layout(ref read_data, layout);

            read_data.span()
        }
    }
}