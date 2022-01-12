// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

abstract contract PublisherService {
	mapping(address => uint256[]) internal publishedArticles;
}
